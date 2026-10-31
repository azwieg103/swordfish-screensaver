#!/bin/sh
# Build and test Swordfish Screensaver on Oracle Solaris 11.4.
set -eu

if [ "$(uname -s)" != "SunOS" ]; then
    echo "This script must run on Oracle Solaris." >&2
    exit 1
fi
if [ "$(uname -r)" != "5.11" ]; then
    echo "Expected Solaris 11 (kernel release 5.11); found $(uname -r)." >&2
    exit 1
fi

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
BUILD_DIR="${BUILD_DIR:-$ROOT/build-solaris11}"
JOBS="${JOBS:-2}"

command -v cmake >/dev/null 2>&1 || {
    echo "CMake is required. Install the Solaris developer/build/cmake package." >&2
    exit 1
}
command -v c++ >/dev/null 2>&1 || {
    echo "A C++17 compiler is required (GCC recommended)." >&2
    exit 1
}

cmake -S "$ROOT" -B "$BUILD_DIR" -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTING=ON
cmake --build "$BUILD_DIR" --parallel "$JOBS"
ctest --test-dir "$BUILD_DIR" --output-on-failure
"$BUILD_DIR/swordfish-screensaver" --help

mkdir -p "$ROOT/dist"
tar -czf "$ROOT/dist/swordfish-solaris11-$(uname -p).tar.gz" \
    -C "$BUILD_DIR" swordfish-screensaver
echo "Solaris build complete: $ROOT/dist/swordfish-solaris11-$(uname -p).tar.gz"
