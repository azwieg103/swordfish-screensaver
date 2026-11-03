Name:           swordfish-screensaver
Version:        0.2.1
Release:        4%{?dist}
Summary:        Multi-monitor circular plasma animation
License:        GPL-3.0-or-later
URL:            https://github.com/azwieg103/swordfish-screensaver
Source0:        %{name}-%{version}.tar.gz
BuildRequires:  cmake >= 3.20
BuildRequires:  extra-cmake-modules
BuildRequires:  kf6-plasma-devel
BuildRequires:  gcc-c++
BuildRequires:  git
BuildRequires:  make
BuildRequires:  qt6-qtbase-devel
BuildRequires:  qt6-qtdeclarative-devel
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
desktop idle launcher. GNOME Mutter or X11 idle detection is used where
available. The desktop environment remains responsible for secure locking.

%prep
%autosetup

%build
%cmake -DCMAKE_BUILD_TYPE=Release
%cmake_build

%install
%cmake_install

# Install the KDE Plasma 6 wallpaper package
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
%{_datadir}/plasma/wallpapers/org.zwiegnet.swordfish/contents/ui/org/zwiegnet/swordfish/geometry/qmldir
%{_datadir}/plasma/wallpapers/org.zwiegnet.swordfish/contents/ui/org/zwiegnet/swordfish/geometry/swordfishgeometryplugin.so

%changelog
* Tue Nov 03 2026 Open Source Contributors <noreply@example.invalid> - 0.2.1-4
- Add a QScreen-backed helper for dynamic virtual desktop and per-screen geometry.
- Recalculate display geometry automatically when monitor layouts change.
