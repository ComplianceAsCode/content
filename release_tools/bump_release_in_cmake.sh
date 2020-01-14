#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONTENT_REPO_ROOT="$(cd "$SCRIPT_DIR" && cd .. && pwd)"
CMAKE_FILE="$CONTENT_REPO_ROOT/CMakeLists.txt"

next_version=$1

_version_triplet=($(echo "$next_version" | tr "." "\n"))
_version_names=(SSG_MAJOR_VERSION SSG_MINOR_VERSION SSG_PATCH_VERSION)
for i in 0 1 2
do
    sed -i "s/set(\s*${_version_names[$i]}\s\+[0-9]\+\s*)/set(${_version_names[$i]} ${_version_triplet[$i]})/" $CMAKE_FILE
done
