Name:           swordfish-screensaver
Version:        0.2.0
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
An independent cross-platform SDL2/OpenGL application that renders an original
circular plasma beam across the virtual desktop. Each monitor displays its
portion of one synchronized animation. SDL2 is built from a pinned upstream
release when a system SDL2 development package is unavailable.

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

%changelog
* Fri Oct 30 2026 Open Source Contributors <noreply@example.invalid> - 0.2.0-1
- Add synchronized multi-monitor circular plasma animation and green color presets.
