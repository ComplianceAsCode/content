#!/bin/bash

set -euo pipefail

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
pushd "$DIR/.." > /dev/null

rm -rf build-py2 build-py3

mkdir -p build-py2
pushd build-py2 > /dev/null
rm -rf *
cmake -G Ninja -DPYTHON_EXECUTABLE=/usr/bin/python2 ../
ninja
popd > /dev/null

mkdir -p build-py3
pushd build-py3 > /dev/null
rm -rf *
cmake -G Ninja -DPYTHON_EXECUTABLE=/usr/bin/python3 ../
ninja
popd > /dev/null

./utils/compare_generated.sh ./build-py2 ./build-py3 ovals
./utils/compare_generated.sh ./build-py2 ./build-py3 fixes

popd > /dev/null
