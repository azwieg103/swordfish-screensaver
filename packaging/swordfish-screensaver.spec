Name:           swordfish-screensaver
Version:        0.2.1
Release:        46%{?dist}
Summary:        Multi-monitor circular plasma animation
License:        GPL-3.0-or-later
URL:            https://github.com/azwieg103/swordfish-screensaver
Source0:        %{name}-%{version}.tar.gz
BuildRequires:  cmake >= 3.20
BuildRequires:  extra-cmake-modules
BuildRequires:  libplasma-devel
BuildRequires:  kf6-kcoreaddons-devel
BuildRequires:  gcc-c++
BuildRequires:  git
BuildRequires:  make
BuildRequires:  qt6-qtbase-devel
BuildRequires:  qt6-qtdeclarative-devel
BuildRequires:  qt6-qtshadertools-devel
BuildRequires:  mesa-libGL-devel
BuildRequires:  libX11-devel
BuildRequires:  libXext-devel
BuildRequires:  libXrandr-devel
BuildRequires:  libXrender-devel
BuildRequires:  libXfixes-devel
BuildRequires:  libXi-devel
BuildRequires:  libXcursor-devel
BuildRequires:  libXinerama-devel

%description
An independent SDL2/OpenGL multi-monitor plasma animation with an optional
desktop idle launcher. The KDE Plasma 6 wallpaper uses a GPU fragment shader
with a shared monotonic animation clock. The desktop environment remains
responsible for secure locking.

%prep
%autosetup

%build
%cmake -DCMAKE_BUILD_TYPE=Release
%cmake_build

%install
%cmake_install

mkdir -p %{buildroot}%{_datadir}/plasma/wallpapers/org.zwiegnet.swordfish
cp -a packaging/plasma6/package/. %{buildroot}%{_datadir}/plasma/wallpapers/org.zwiegnet.swordfish/

%files
%license LICENSE
%doc README.md
%{_bindir}/swordfish-screensaver
%{_bindir}/swordfish-idle
%{_datadir}/applications/swordfish-idle.desktop
%{_datadir}/plasma/wallpapers/org.zwiegnet.swordfish/metadata.json
%{_datadir}/plasma/wallpapers/org.zwiegnet.swordfish/contents/config/main.xml
%{_datadir}/plasma/wallpapers/org.zwiegnet.swordfish/contents/ui/config.qml
%{_datadir}/plasma/wallpapers/org.zwiegnet.swordfish/contents/ui/main.qml
%{_libdir}/qt6/qml/org/zwiegnet/swordfish/geometry/qmldir
%{_libdir}/qt6/qml/org/zwiegnet/swordfish/geometry/libswordfishgeometryplugin.so

%changelog
* Wed Nov 04 2026 Open Source Contributors <noreply@example.invalid> - 0.2.1-46
- In Random mode, hold a randomly selected direction for three full cycles, then reverse for three cycles.
- Repeat alternating three-cycle clockwise and counter-clockwise groups with synchronized multi-monitor timing.

* Wed Nov 04 2026 Open Source Contributors <noreply@example.invalid> - 0.2.1-45
- Make fade-in movement part of the same revolution phase to prevent an orbit/trail replay at cycle boundaries.
- Keep orb, comet trail, and orbit ring phase-continuous through fade-in and fade-out.

* Wed Nov 04 2026 Open Source Contributors <noreply@example.invalid> - 0.2.1-44
- Add Fireball red/orange color theme to the Screen Locking color selector.
- Rename Green palette setting to Color theme.

* Wed Nov 04 2026 Open Source Contributors <noreply@example.invalid> - 0.2.1-43
- Make Screen Locking wallpaper settings scrollable to expose all controls.
- Extend fade transitions to seven seconds and default blackout duration to seven seconds.
- Resume orbital movement during fade-in, revealing the orb before the orbit ring.

* Wed Nov 04 2026 Open Source Contributors <noreply@example.invalid> - 0.2.1-42
- Use a plain string model for travel direction in the Screen Locking configuration UI.
- Keep Random, Clockwise, and Counterclockwise explicitly selectable.

* Wed Nov 04 2026 Open Source Contributors <noreply@example.invalid> - 0.2.1-41
- Keep orbit motion continuous through fade-out and blackout instead of resetting to the same point.
- Randomize the next visible orbit's starting position and direction while preserving monitor synchronization.

* Wed Nov 04 2026 Open Source Contributors <noreply@example.invalid> - 0.2.1-40
- Move meteor flame intensity control next to orb count for visibility.
- Label the control explicitly and retain its 0-200% range.

* Wed Nov 04 2026 Open Source Contributors <noreply@example.invalid> - 0.2.1-39
- Fade the orb and orbit smoothly to black and back between revolutions.
- Add adjustable blackout duration, defaulting to ten seconds.
- Clarify Random travel direction as a new choice for every orbit.

* Wed Nov 04 2026 Open Source Contributors <noreply@example.invalid> - 0.2.1-38
- Choose a new pseudo-random travel direction for each orbit cycle.
- Add configurable flame intensity from 0% to 200%.

* Wed Nov 04 2026 Open Source Contributors <noreply@example.invalid> - 0.2.1-37
- Add a smooth, animated flame plume trailing behind each round orb.
- Keep flames aligned with the orbit tangent and selected plasma palette.

* Wed Nov 04 2026 Open Source Contributors <noreply@example.invalid> - 0.2.1-36
- Animate one full orbit per cycle, then hide the entire animation for five seconds.
- Retain configurable direction, speed, orb count, palette, glow, and comet trail.
- Remove the previous radiating-pulse controls, which are replaced by the blank pause.

* Wed Nov 04 2026 Open Source Contributors <noreply@example.invalid> - 0.2.1-35
- Set Emerald as the default plasma palette for new configurations.

* Wed Nov 04 2026 Open Source Contributors <noreply@example.invalid> - 0.2.1-34
- Skip the pulse pause entirely when the pulse effect is disabled.

* Wed Nov 04 2026 Open Source Contributors <noreply@example.invalid> - 0.2.1-33
- Add pulse enable/disable and adjustable pulse intensity controls.

* Wed Nov 04 2026 Open Source Contributors <noreply@example.invalid> - 0.2.1-32
- Add configurable pulse interval with radiating orb and orbit-ring effects.
- Make the default direction cycle clockwise, counterclockwise, then pulse.
- Retain fixed clockwise and counterclockwise travel modes.

* Wed Nov 04 2026 Open Source Contributors <noreply@example.invalid> - 0.2.1-31
- Expand wide oval horizontal radius to use more of the virtual desktop.

* Wed Nov 04 2026 Open Source Contributors <noreply@example.invalid> - 0.2.1-30
- Follow the orbit path with a connected, curved comet trail.
- Use the selected palette consistently for orb cores and trails.
- Add a configurable comet trail length slider.

* Wed Nov 04 2026 Open Source Contributors <noreply@example.invalid> - 0.2.1-28
- Bind wallpaper rendering properties to Plasma's live configuration map.

* Wed Nov 04 2026 Open Source Contributors <noreply@example.invalid> - 0.2.1-27
- Add independent orb brightness control from 10% to 200%.

* Wed Nov 04 2026 Open Source Contributors <noreply@example.invalid> - 0.2.1-26
- Fix palette, orbit shape, and starting direction combo-box configuration bindings.

* Wed Nov 04 2026 Open Source Contributors <noreply@example.invalid> - 0.2.1-25
- Use one default glowing orb with a smooth circular comet tail.
- Run four laps forward, four laps in reverse, then pulse and repeat.

* Wed Nov 04 2026 Open Source Contributors <noreply@example.invalid> - 0.2.1-24
- Add occasional staggered comet flashes with a brief afterglow.
- Boost the comet head and tapered tail during each pulse.

* Wed Nov 04 2026 Open Source Contributors <noreply@example.invalid> - 0.2.1-23
- Add tapered, fading GPU comet tails behind each moving orb.
- Preserve the continuous thin orbit and existing frame-synchronized renderer.

* Wed Nov 04 2026 Open Source Contributors <noreply@example.invalid> - 0.2.1-22
- Replace the animated Canvas with a GPU fragment-shader renderer for Plasma 6.
- Compile the shader to Qt QShader format during the CMake build.
- Drive all monitor instances from one shared native monotonic animation clock.
- Use Qt Quick frame-synchronized FrameAnimation for presentation updates.
- Make date and time overlays optional and disabled by default.

* Wed Nov 04 2026 Open Source Contributors <noreply@example.invalid> - 0.2.1-21
- Drive animation updates with Qt requestAnimationFrame to align with scene composition.
- Use cooperative Canvas rendering and reduce per-frame orbit path complexity.
- Remove solid arc overlays that created persistent trails around the moving orbs.
- Keep two default orbs moving over the continuously visible thin orbit.
