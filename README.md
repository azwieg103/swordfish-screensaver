# Swordfish Screensaver

An open-source, hardware-accelerated plasma-trail screensaver for Linux, with AlmaLinux 10 RPM packaging as a primary goal.

The visual target is a bright yellow-green plasma comet: a glowing core, fluid curved tail, and fading particles moving over a deep black background. The project aims to capture that *kind* of cinematic atmosphere with an original implementation and original artwork—not to reproduce or bundle footage, assets, or code from any film.

## Concept artwork

![Original Swordfish Screensaver concept art: multiple dark displays showing glowing yellow-green plasma trails](assets/swordfish-concept.svg)

The illustration above was created specifically for this repository as original vector artwork. It is not a screenshot or frame from a movie. The artwork is dedicated to the public domain under [CC0 1.0](https://creativecommons.org/publicdomain/zero/1.0/).

## Project goals

- Smooth animated plasma trails with a luminous core, glow, and particle falloff.
- Configurable colors, speed, trail length, and movement behavior.
- Multi-monitor support.
- Standalone preview mode for development and testing.
- Linux desktop integration, with XScreenSaver-compatible invocation where feasible.
- Reproducible source builds and RPM packaging targeting AlmaLinux 10 / EL10.
- Automated build and test checks with GitHub Actions.

## Status

**Early project setup.** The artwork and project direction are established; the animation engine, desktop integration, packaging, and automated RPM builds still need to be implemented and tested.

## Planned layout

```text
src/                    Animation engine and application
assets/                 Original project artwork
packaging/              RPM spec and packaging helpers
tests/                  Tests
.github/workflows/      CI and RPM build workflows
CMakeLists.txt          Build configuration
```

## Build and install

Build instructions and RPM installation steps will be added after the initial implementation and dependency list are verified on AlmaLinux 10. Until then, no prebuilt RPM is claimed to be available.

## Contributing

Issues and pull requests are welcome. Please include distribution/version details and logs for build or desktop-integration problems.

## Name and affiliation

“Swordfish Screensaver” is an independent open-source project name referring to its visual concept. It is not affiliated with, endorsed by, or sponsored by the creators or distributors of the film *Swordfish*. No film footage, screenshots, logos, or extracted assets are included.

## License

The application source is intended to be released under **GNU GPL-3.0-or-later**. The original concept SVG in `assets/swordfish-concept.svg` is separately dedicated to the public domain under **CC0 1.0**. License files for the source code will be included with the initial implementation.
