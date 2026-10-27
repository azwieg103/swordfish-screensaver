#include <SDL.h>
#include <SDL_opengl.h>

#include <algorithm>
#include <cmath>
#include <cstdlib>
#include <iostream>
#include <string>
#include <utility>
#include <vector>

namespace {
constexpr double kPi = 3.14159265358979323846;

struct Options {
    bool windowed = false;
    int monitor = -1;
};

Options parseArgs(int argc, char** argv) {
    Options options;
    for (int i = 1; i < argc; ++i) {
        const std::string arg(argv[i]);
        if (arg == "--windowed") {
            options.windowed = true;
        } else if (arg == "--monitor" && i + 1 < argc) {
            options.monitor = std::max(0, std::atoi(argv[++i]));
        } else if (arg == "--help" || arg == "-h") {
            std::cout << "Swordfish Screensaver - original procedural plasma animation\n"
                         "Usage: swordfish-screensaver [--windowed] [--monitor N]\n"
                         "  --windowed   Show a resizable preview window\n"
                         "  --monitor N  Use display N (zero-based)\n"
                         "Keys: Esc/Q quit, F toggle fullscreen\n";
            std::exit(0);
        } else {
            std::cerr << "Unknown option: " << arg << "\nUse --help for options.\n";
            std::exit(2);
        }
    }
    return options;
}

void drawTrail(float time, float cx, float cy, float phase, int segments) {
    const float drift = 0.16f * std::sin(time * 0.31f + phase);
    const float sweep = 0.34f * std::sin(time * 0.22f + phase * 1.7f);
    const float direction = std::sin(time * 0.17f + phase) > 0.0f ? 1.0f : -1.0f;
    const float length = 0.26f + 0.14f * (0.5f + 0.5f * std::sin(time * 0.73f + phase));
    const float headX = cx + sweep;
    const float headY = cy + drift;

    std::vector<std::pair<float, float>> points;
    points.reserve(static_cast<std::size_t>(segments + 1));
    for (int i = 0; i <= segments; ++i) {
        const float u = static_cast<float>(i) / static_cast<float>(segments);
        const float back = u * length;
        const float x = headX - direction * back;
        const float curve = std::sin(u * static_cast<float>(kPi) * 1.2f + time * 0.8f + phase) * 0.09f * u;
        const float y = headY + curve + back * 0.22f * std::sin(time * 0.4f + phase);
        points.emplace_back(x, y);
    }

    // Three additive layers create a soft halo, colored body, and hot inner filament.
    for (int layer = 0; layer < 3; ++layer) {
        const float width = layer == 0 ? 4.5f : layer == 1 ? 2.2f : 1.0f;
        glLineWidth(width);
        glBegin(GL_LINE_STRIP);
        for (std::size_t i = 0; i < points.size(); ++i) {
            const float fade = 1.0f - static_cast<float>(i) / static_cast<float>(points.size());
            if (layer == 0) glColor4f(0.38f, 1.0f, 0.025f, 0.025f + 0.12f * fade);
            if (layer == 1) glColor4f(0.72f, 1.0f, 0.08f, 0.05f + 0.36f * fade);
            if (layer == 2) glColor4f(1.0f, 0.98f, 0.70f, 0.12f + 0.82f * fade);
            glVertex2f(points[i].first, points[i].second);
        }
        glEnd();
    }

    // Procedural glowing head, generated entirely in code.
    const float pulse = 0.009f + 0.004f * (0.5f + 0.5f * std::sin(time * 4.0f + phase));
    for (int ring = 7; ring >= 1; --ring) {
        const float radius = pulse * static_cast<float>(ring);
        const float alpha = 0.012f + 0.022f * static_cast<float>(8 - ring);
        glColor4f(0.70f, 1.0f, 0.08f, alpha);
        glBegin(GL_TRIANGLE_FAN);
        glVertex2f(headX, headY);
        for (int j = 0; j <= 32; ++j) {
            const float angle = static_cast<float>(j) * static_cast<float>(2.0 * kPi / 32.0);
            glVertex2f(headX + std::cos(angle) * radius, headY + std::sin(angle) * radius);
        }
        glEnd();
    }
    glPointSize(4.0f);
    glColor4f(1.0f, 1.0f, 0.82f, 0.98f);
    glBegin(GL_POINTS);
    glVertex2f(headX, headY);
    glEnd();
}

void render(float time, int width, int height) {
    glViewport(0, 0, width, height);
    glClearColor(0.004f, 0.006f, 0.009f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    // Use normalized coordinates so the trails occupy a consistent fraction of each display.
    (void)width;
    (void)height;
    glOrtho(-1.0, 1.0, -1.0, 1.0, -1.0, 1.0);
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE);
    glEnable(GL_LINE_SMOOTH);
    glHint(GL_LINE_SMOOTH_HINT, GL_NICEST);
    glDisable(GL_DEPTH_TEST);
    for (int i = 0; i < 4; ++i) {
        const float phase = static_cast<float>(i) * 1.81f;
        const float y = -0.58f + static_cast<float>(i) * 0.37f;
        drawTrail(time, 0.02f * std::sin(time * 0.11f + phase), y, phase, 96);
    }
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
    const int displayCount = SDL_GetNumVideoDisplays();
    if (displayCount < 1) {
        std::cerr << "No displays found: " << SDL_GetError() << '\n';
        SDL_Quit();
        return 1;
    }
    const int display = options.monitor < 0 ? 0 : std::min(options.monitor, displayCount - 1);
    SDL_Rect bounds{};
    if (SDL_GetDisplayBounds(display, &bounds) != 0) {
        std::cerr << "Cannot query display: " << SDL_GetError() << '\n';
        SDL_Quit();
        return 1;
    }

    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 2);
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 1);
    SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1);
    SDL_GL_SetAttribute(SDL_GL_DEPTH_SIZE, 0);
    SDL_GL_SetAttribute(SDL_GL_ALPHA_SIZE, 8);

    Uint32 flags = SDL_WINDOW_OPENGL | SDL_WINDOW_ALLOW_HIGHDPI;
    int x = bounds.x, y = bounds.y, width = bounds.w, height = bounds.h;
    if (options.windowed) {
        flags |= SDL_WINDOW_RESIZABLE;
        width = 1100;
        height = 650;
        x = SDL_WINDOWPOS_CENTERED_DISPLAY(display);
        y = SDL_WINDOWPOS_CENTERED_DISPLAY(display);
    } else {
        flags |= SDL_WINDOW_FULLSCREEN_DESKTOP;
    }

    SDL_Window* window = SDL_CreateWindow("Swordfish Screensaver", x, y, width, height, flags);
    if (!window) {
        std::cerr << "Window creation failed: " << SDL_GetError() << '\n';
        SDL_Quit();
        return 1;
    }
    SDL_GLContext context = SDL_GL_CreateContext(window);
    if (!context) {
        std::cerr << "OpenGL context creation failed: " << SDL_GetError() << '\n';
        SDL_DestroyWindow(window);
        SDL_Quit();
        return 1;
    }
    SDL_GL_SetSwapInterval(1);

    bool running = true;
    bool fullscreen = !options.windowed;
    const Uint64 start = SDL_GetPerformanceCounter();
    const double frequency = static_cast<double>(SDL_GetPerformanceFrequency());

    while (running) {
        SDL_Event event;
        while (SDL_PollEvent(&event)) {
            if (event.type == SDL_QUIT) running = false;
            if (event.type == SDL_KEYDOWN) {
                const SDL_Keycode key = event.key.keysym.sym;
                if (key == SDLK_ESCAPE || key == SDLK_q) running = false;
                if (key == SDLK_f) {
                    fullscreen = !fullscreen;
                    SDL_SetWindowFullscreen(window, fullscreen ? SDL_WINDOW_FULLSCREEN_DESKTOP : 0);
                }
            }
        }
        int drawableWidth = 0, drawableHeight = 0;
        SDL_GL_GetDrawableSize(window, &drawableWidth, &drawableHeight);
        const float time = static_cast<float>(
            static_cast<double>(SDL_GetPerformanceCounter() - start) / frequency);
        render(time, drawableWidth, drawableHeight);
        SDL_GL_SwapWindow(window);
    }

    SDL_GL_DeleteContext(context);
    SDL_DestroyWindow(window);
    SDL_Quit();
    return 0;
}
