Name:           swordfish-screensaver
Version:        0.1.0
Release:        2%{?dist}
Summary:        Procedural plasma-trail animation preview
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
An independent cross-platform SDL2/OpenGL application that renders original,
procedurally generated plasma trails. SDL2 is built from a pinned upstream
release when a system SDL2 development package is unavailable. This prototype
is an application preview and does not yet integrate with desktop idle/lock services.

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
* Tue Oct 27 2026 Open Source Contributors <noreply@example.invalid> - 0.1.0-2
- Build with pinned SDL2 source when system SDL2 development files are unavailable.
* Tue Oct 27 2026 Open Source Contributors <noreply@example.invalid> - 0.1.0-1
- Initial cross-platform prototype and RPM packaging.
