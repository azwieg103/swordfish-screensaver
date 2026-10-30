#include <SDL.h>
#include <SDL_opengl.h>

#include <algorithm>
#include <cmath>
#include <cstdlib>
#include <iostream>
#include <string>
#include <vector>

namespace {
constexpr double kPi = 3.14159265358979323846;

struct Options {
    bool windowed = false;
    int monitor = -1;
    float greenR = 0.28f, greenG = 1.0f, greenB = 0.035f;
};

struct Display {
    SDL_Rect bounds{};
    SDL_Window* window = nullptr;
    SDL_GLContext context = nullptr;
};

Options parseArgs(int argc, char** argv) {
    Options o;
    for (int i = 1; i < argc; ++i) {
        const std::string arg(argv[i]);
        if (arg == "--windowed") o.windowed = true;
        else if (arg == "--monitor" && i + 1 < argc) o.monitor = std::max(0, std::atoi(argv[++i]));
        else if (arg == "--green" && i + 1 < argc) {
            const std::string preset(argv[++i]);
            if (preset == "lime") o.greenR = 0.62f, o.greenG = 1.0f, o.greenB = 0.015f;
            else if (preset == "emerald") o.greenR = 0.02f, o.greenG = 0.88f, o.greenB = 0.34f;
            else if (preset == "teal") o.greenR = 0.02f, o.greenG = 0.92f, o.greenB = 0.72f;
            else if (preset == "classic") o.greenR = 0.28f, o.greenG = 1.0f, o.greenB = 0.035f;
            else {
                std::cerr << "Unknown green preset: " << preset << "\n";
                std::exit(2);
            }
        } else if (arg == "--help" || arg == "-h") {
            std::cout << "Swordfish Screensaver 0.2.0\n"
                         "Usage: swordfish-screensaver [--windowed] [--monitor N] [--green classic|lime|emerald|teal]\n"
                         "Fullscreen uses every monitor; --monitor N limits fullscreen to one display.\n"
                         "--windowed opens a preview. Keys: Esc/Q quit, F toggle fullscreen.\n";
            std::exit(0);
        } else {
            std::cerr << "Unknown option: " << arg << "\nUse --help for options.\n";
            std::exit(2);
        }
    }
    return o;
}

void vertex(float x, float y) { glVertex2f(x, y); }

void glowDot(float x, float y, float radius, float r, float g, float b) {
    for (int ring = 8; ring >= 1; --ring) {
        const float rr = radius * static_cast<float>(ring);
        glColor4f(r, g, b, 0.012f + 0.018f * static_cast<float>(8 - ring));
        glBegin(GL_TRIANGLE_FAN);
        vertex(x, y);
        for (int j = 0; j <= 36; ++j) {
            const float a = static_cast<float>(j) * static_cast<float>(2.0 * kPi / 36.0);
            vertex(x + std::cos(a) * rr, y + std::sin(a) * rr);
        }
        glEnd();
    }
}

void drawBeam(double angle, double direction, float rx, float ry, const Options& o) {
    const float cx = rx * 0.0f;
    (void)cx;
    const float headX = rx * std::cos(static_cast<float>(angle));
    const float headY = ry * std::sin(static_cast<float>(angle));
    // A tapered arc trail follows the moving pulse around the shared desktop orbit.
    for (int layer = 0; layer < 3; ++layer) {
        glLineWidth(layer == 0 ? 13.0f : layer == 1 ? 5.0f : 1.8f);
        glBegin(GL_LINE_STRIP);
        for (int i = 0; i <= 150; ++i) {
            const float u = static_cast<float>(i) / 150.0f;
            const double a = angle - direction * (0.95 * u);
            const float fade = 1.0f - u;
            if (layer == 0) glColor4f(o.greenR, o.greenG, o.greenB, 0.012f + 0.075f * fade);
            if (layer == 1) glColor4f(o.greenR, o.greenG, o.greenB, 0.025f + 0.25f * fade);
            if (layer == 2) glColor4f(0.82f, 1.0f, 0.76f, 0.08f + 0.76f * fade);
            vertex(rx * std::cos(static_cast<float>(a)), ry * std::sin(static_cast<float>(a)));
        }
        glEnd();
    }
    glowDot(headX, headY, 0.009f, o.greenR, o.greenG, o.greenB);
    glPointSize(4.0f);
    glColor4f(1.0f, 1.0f, 0.88f, 1.0f);
    glBegin(GL_POINTS); vertex(headX, headY); glEnd();
}

void render(double t, int drawableW, int drawableH, const SDL_Rect& local,
            const SDL_Rect& virtualBounds, const Options& o) {
    glViewport(0, 0, drawableW, drawableH);
    glClearColor(0.002f, 0.004f, 0.008f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    // Every monitor renders from the same virtual-desktop coordinate system.
    glOrtho(local.x, local.x + local.w, local.y + local.h, local.y, -1.0, 1.0);
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE);
    glEnable(GL_LINE_SMOOTH);
    glHint(GL_LINE_SMOOTH_HINT, GL_NICEST);
    glDisable(GL_DEPTH_TEST);

    const double cx = virtualBounds.x + virtualBounds.w * 0.5;
    const double cy = virtualBounds.y + virtualBounds.h * 0.5;
    const float scale = static_cast<float>(std::min(virtualBounds.w, virtualBounds.h));
    const float rx = static_cast<float>(virtualBounds.w) * 0.43f;
    const float ry = static_cast<float>(virtualBounds.h) * 0.43f;
    const double rotations = t / 5.0; // one revolution every five seconds
    const int leg = static_cast<int>(std::floor(rotations / 5.0));
    const double within = rotations - leg * 5.0;
    const double direction = (leg % 2 == 0) ? 1.0 : -1.0;
    const double angle = direction > 0 ? within * (2.0 * kPi) : (5.0 - within) * (2.0 * kPi);
    // Smoothly morph from one pulse to two, four, then back to one.
    const double cycle = std::fmod(t, 32.0);
    const double splitWave = (cycle < 8.0 || cycle >= 24.0) ? 0.0 :
                             (cycle < 12.0 ? (cycle - 8.0) / 4.0 :
                              cycle < 20.0 ? 1.0 : (24.0 - cycle) / 4.0);
    const int beams = splitWave < 0.34 ? 1 : splitWave < 0.84 ? 2 : 4;
    (void)scale;
    glPushMatrix();
    glTranslatef(static_cast<float>(cx), static_cast<float>(cy), 0.0f);
    for (int i = 0; i < beams; ++i) {
        const double a = angle + (2.0 * kPi * i / beams);
        drawBeam(a, direction, rx, ry, o);
    }
    glPopMatrix();
    glDisable(GL_BLEND);
}
} // namespace

int main(int argc, char** argv) {
#ifdef SDL_MAIN_HANDLED
    SDL_SetMainReady();
#endif
    const Options options = parseArgs(argc, argv);
    if (SDL_Init(SDL_INIT_VIDEO | SDL_INIT_TIMER) != 0) {
        std::cerr << "SDL initialization failed: " << SDL_GetError() << '\n';
        return 1;
    }
    const int count = SDL_GetNumVideoDisplays();
    if (count < 1) { std::cerr << "No displays found: " << SDL_GetError() << '\n'; SDL_Quit(); return 1; }

    std::vector<Display> displays;
    SDL_Rect virtualBounds{};
    const int first = options.monitor < 0 ? 0 : std::min(options.monitor, count - 1);
    const int last = options.monitor < 0 ? count : first + 1;
    for (int i = first; i < last; ++i) {
        Display d;
        if (SDL_GetDisplayBounds(i, &d.bounds) != 0) {
            std::cerr << "Cannot query display " << i << ": " << SDL_GetError() << '\n';
            continue;
        }
        if (displays.empty()) virtualBounds = d.bounds;
        else {
            const int left = std::min(virtualBounds.x, d.bounds.x);
            const int top = std::min(virtualBounds.y, d.bounds.y);
            const int right = std::max(virtualBounds.x + virtualBounds.w, d.bounds.x + d.bounds.w);
            const int bottom = std::max(virtualBounds.y + virtualBounds.h, d.bounds.y + d.bounds.h);
            virtualBounds = {left, top, right - left, bottom - top};
        }
        displays.push_back(d);
    }
    if (displays.empty()) { SDL_Quit(); return 1; }
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 2);
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 1);
    SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1);
    SDL_GL_SetAttribute(SDL_GL_DEPTH_SIZE, 0);
    SDL_GL_SetAttribute(SDL_GL_ALPHA_SIZE, 8);

    for (std::size_t i = 0; i < displays.size(); ++i) {
        auto& d = displays[i];
        int x = d.bounds.x, y = d.bounds.y, w = d.bounds.w, h = d.bounds.h;
        Uint32 flags = SDL_WINDOW_OPENGL | SDL_WINDOW_ALLOW_HIGHDPI;
        if (options.windowed) {
            if (i > 0) continue;
            flags |= SDL_WINDOW_RESIZABLE;
            w = 1100; h = 650;
            x = SDL_WINDOWPOS_CENTERED_DISPLAY(first);
            y = SDL_WINDOWPOS_CENTERED_DISPLAY(first);
        } else flags |= SDL_WINDOW_FULLSCREEN_DESKTOP;
        d.window = SDL_CreateWindow("Swordfish Screensaver", x, y, w, h, flags);
        if (!d.window) { std::cerr << "Window creation failed: " << SDL_GetError() << '\n'; continue; }
        d.context = SDL_GL_CreateContext(d.window);
        if (!d.context) { std::cerr << "OpenGL context creation failed: " << SDL_GetError() << '\n'; SDL_DestroyWindow(d.window); d.window = nullptr; continue; }
        SDL_GL_SetSwapInterval(1);
    }
    bool running = true, fullscreen = !options.windowed;
    const Uint64 start = SDL_GetPerformanceCounter();
    const double frequency = static_cast<double>(SDL_GetPerformanceFrequency());
    while (running) {
        SDL_Event e;
        while (SDL_PollEvent(&e)) {
            if (e.type == SDL_QUIT) running = false;
            if (e.type == SDL_KEYDOWN) {
                const SDL_Keycode key = e.key.keysym.sym;
                if (key == SDLK_ESCAPE || key == SDLK_q) running = false;
                if (key == SDLK_f) {
                    fullscreen = !fullscreen;
                    for (auto& d : displays) if (d.window)
                        SDL_SetWindowFullscreen(d.window, fullscreen ? SDL_WINDOW_FULLSCREEN_DESKTOP : 0);
                }
            }
        }
        const double t = static_cast<double>(SDL_GetPerformanceCounter() - start) / frequency;
        for (auto& d : displays) {
            if (!d.window || !d.context) continue;
            SDL_GL_MakeCurrent(d.window, d.context);
            int w = 0, h = 0;
            SDL_GL_GetDrawableSize(d.window, &w, &h);
            SDL_Rect view = d.bounds;
            if (options.windowed) {
                int wx, wy; SDL_GetWindowPosition(d.window, &wx, &wy);
                int ww, wh; SDL_GetWindowSize(d.window, &ww, &wh);
                view = {wx, wy, ww, wh};
            }
            render(t, w, h, view, virtualBounds, options);
            SDL_GL_SwapWindow(d.window);
        }
    }
    for (auto& d : displays) {
        if (d.context) SDL_GL_DeleteContext(d.context);
        if (d.window) SDL_DestroyWindow(d.window);
    }
    SDL_Quit();
    return 0;
}
