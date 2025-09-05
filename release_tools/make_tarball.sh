#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONTENT_REPO_ROOT="$(cd "$SCRIPT_DIR" && cd .. && pwd)"
BUILDDIR="$CONTENT_REPO_ROOT/build"

version=$1

die()
{
    echo "$1"
    exit 1
}

echo Generating source code tarball
ncpu=$(nproc) # This won't return number of physical core, but it shouldn't be problem
(cd "$BUILDDIR" && cmake .. && make -j $ncpu package_source) &> package_source.log || die "Error making package_source. Check package_source.log for errors"
mkdir artifacts/
mv $BUILDDIR/scap-security-guide-$version.tar.bz2 artifacts/
