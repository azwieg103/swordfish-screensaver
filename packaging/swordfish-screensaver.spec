Name:           swordfish-screensaver
Version:        0.2.1
Release:        1%{?dist}
Summary:        Multi-monitor circular plasma animation
License:        GPL-3.0-or-later
URL:            https://github.com/azwieg103/swordfish-screensaver
Source0:        %{name}-%{version}.tar.gz
BuildRequires:  cmake >= 3.20
BuildRequires:  gcc-c++
BuildRequires:  git
BuildRequires:  make
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
An independent SDL2/OpenGL multi-monitor circular plasma animation with an
optional KDE X11 idle launcher. KDE continues to manage secure screen locking.

%prep
%autosetup

%build
%cmake -DCMAKE_BUILD_TYPE=Release
%cmake_build

%install
%cmake_install

%files
%license LICENSE
%doc README.md
%{_bindir}/swordfish-screensaver
%{_bindir}/swordfish-idle
%{_datadir}/applications/swordfish-idle.desktop

%changelog
* Fri Oct 30 2026 Open Source Contributors <noreply@example.invalid> - 0.2.1-1
- Add opt-in KDE X11 idle launcher and autostart desktop entry.
