Name:           swordfish-screensaver
Version:        0.1.0
Release:        1%{?dist}
Summary:        Procedural plasma-trail animation preview
License:        GPL-3.0-or-later
URL:            https://github.com/azwieg103/swordfish-screensaver
Source0:        %{name}-%{version}.tar.gz
BuildRequires:  cmake >= 3.20
BuildRequires:  gcc-c++
BuildRequires:  make
BuildRequires:  SDL2-devel
BuildRequires:  mesa-libGL-devel

%description
An independent cross-platform SDL2/OpenGL application that renders original,
procedurally generated plasma trails. This prototype is an application preview
and does not yet integrate with desktop idle/lock services.

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
%{_datadir}/doc/swordfish-screensaver/README.md
%{_datadir}/doc/swordfish-screensaver/LICENSE

%changelog
* Tue Oct 27 2026 Open Source Contributors <noreply@example.invalid> - 0.1.0-1
- Initial cross-platform prototype and RPM packaging.
