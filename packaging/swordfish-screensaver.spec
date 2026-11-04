Name:           swordfish-screensaver
Version:        0.2.1
Release:        32%{?dist}
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
