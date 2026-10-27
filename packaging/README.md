# RPM packaging

Build on an EL-compatible machine with the spec's BuildRequires available.

```bash
sudo dnf install -y rpm-build rpmdevtools cmake gcc-c++ make SDL2-devel mesa-libGL-devel
mkdir -p ~/rpmbuild/{BUILD,BUILDROOT,RPMS,SOURCES,SPECS,SRPMS}
git archive --format=tar.gz --prefix=swordfish-screensaver-0.1.0/ HEAD \
  > ~/rpmbuild/SOURCES/swordfish-screensaver-0.1.0.tar.gz
cp packaging/swordfish-screensaver.spec ~/rpmbuild/SPECS/
rpmbuild -ba ~/rpmbuild/SPECS/swordfish-screensaver.spec
```

The output RPM is under `~/rpmbuild/RPMS/`. Test on a clean AlmaLinux 10 installation before publishing. The application is a standalone preview, not yet a native KDE screensaver plugin.
