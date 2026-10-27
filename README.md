# Swordfish Screensaver

An independent, cross-platform animated plasma-trail screensaver concept for Linux and Windows.

The goal is an original, real-time visual: luminous yellow-green plasma comets with bright cores, curved tails, and fading particles on a dark background. This project draws on a broad science-fiction visual aesthetic; it does **not** reproduce movie frames, use extracted footage, copy proprietary assets, or claim affiliation with any film or studio.

![Original project concept artwork: monitors showing glowing plasma trails](assets/swordfish-concept.svg)

The concept artwork above was created specifically for this repository and is dedicated to the public domain under [CC0 1.0](https://creativecommons.org/publicdomain/zero/1.0/).

## Goals

- Cross-platform C++17 application for Linux and Windows.
- SDL2 for window, input, and display handling; OpenGL for rendering.
- Fullscreen mode, windowed preview, and optional monitor selection.
- Procedurally generated trails—no third-party movie assets or downloaded visual content.
- AlmaLinux 10 RPM packaging and Windows ZIP builds.
- CI builds on Linux and Windows.

## Current status

**Prototype.** This is an application preview, not yet a fully integrated OS screensaver. Native idle/lock integration is platform-specific and will be developed separately.

## Build dependencies

- CMake 3.20+
- C++17 compiler
- SDL2 development package
- OpenGL development libraries / driver

### Linux (AlmaLinux 10)

```bash
sudo dnf install -y cmake gcc-c++ make SDL2-devel mesa-libGL-devel
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build --parallel
./build/swordfish-screensaver --windowed
```

Run fullscreen by omitting `--windowed`. Choose a display index (zero-based) with `--monitor 1`. Press **Esc** or **Q** to exit; press **F** to toggle fullscreen.

### Windows

With Visual Studio 2022 and vcpkg installed:

```powershell
vcpkg install sdl2:x64-windows
cmake -S . -B build -DCMAKE_TOOLCHAIN_FILE="$env:VCPKG_ROOT/scripts/buildsystems/vcpkg.cmake"
cmake --build build --config Release
.`buildReleaseswordfish-screensaver.exe --windowed
```

Windows builds are planned in CI. The distributable ZIP must include the SDL2 runtime DLL alongside the executable.

## RPM packaging

See `packaging/README.md` for RPM build instructions and dependencies.

## Copyright and licensing

- Application source: **GNU GPL-3.0-or-later** (see [LICENSE](LICENSE)).
- Concept artwork: **CC0 1.0** (see [assets/swordfish-concept.svg](assets/swordfish-concept.svg)).
- The animation is procedurally generated. Do not add movie screenshots, clips, extracted frames, logos, soundtrack, or code from unrelated screensavers without confirming rights and documenting the license.
- “Swordfish” is used as a project name to describe the visual concept. This independent project is not affiliated with, endorsed by, or sponsored by any film studio or rights holder. If the name creates trademark confusion, the project can be renamed without changing the technical implementation.

## Roadmap

- [x] Original concept art
- [x] Cross-platform SDL2/OpenGL prototype source
- [x] CMake build configuration
- [x] RPM spec scaffold
- [x] Linux and Windows CI workflows
- [ ] Verify builds on AlmaLinux 10 and Windows
- [ ] Improve particle trails and settings
- [ ] Native screensaver/idle integration for KDE and Windows
- [ ] Published RPM/ZIP release artifacts

Issues and pull requests are welcome. Include OS version, GPU/driver, build logs, and reproduction steps for bugs.
