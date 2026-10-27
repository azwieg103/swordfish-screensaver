# RPM packaging

On AlmaLinux 10, the project uses a system SDL2 package if one is available.
Otherwise CMake downloads and builds a pinned SDL2 release automatically.

Install the compiler, CMake, Git (used by CMake's source fetch), OpenGL, and X11
development headers:

```bash
sudo dnf install -y rpm-build rpmdevtools cmake gcc-c++ git make mesa-libGL-devel libX11-devel libXext-devel libXrandr-devel libXrender-devel libXfixes-devel libXi-devel libXcursor-devel libXinerama-devel
```

Build the RPM from the repository root:

```bash
mkdir -p ~/rpmbuild/{BUILD,BUILDROOT,RPMS,SOURCES,SPECS,SRPMS}
git archive --format=tar.gz --prefix=swordfish-screensaver-0.1.0/ HEAD \
  > ~/rpmbuild/SOURCES/swordfish-screensaver-0.1.0.tar.gz
cp packaging/swordfish-screensaver.spec ~/rpmbuild/SPECS/
rpmbuild -ba ~/rpmbuild/SPECS/swordfish-screensaver.spec
```

The output RPM is under `~/rpmbuild/RPMS/`. The first build needs network access
to fetch the pinned SDL2 source if SDL2 development files are not installed.
The resulting app is a standalone preview, not yet a native KDE screensaver plugin.
