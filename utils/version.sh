#!/bin/bash

content_cmakelists="$(realpath $(dirname ${BASH_SOURCE[0]}))/../CMakeLists.txt"
major_version=$(grep "set(SSG_MAJOR_VERSION" "$content_cmakelists" | sed "s/.*SSG_MAJOR_VERSION \([[:digit:]]*\).*/\1/")
minor_version=$(grep "set(SSG_MINOR_VERSION" "$content_cmakelists" | sed "s/.*SSG_MINOR_VERSION \([[:digit:]]*\).*/\1/")
patch_version=$(grep "set(SSG_PATCH_VERSION" "$content_cmakelists" | sed "s/.*SSG_PATCH_VERSION \([[:digit:]]*\).*/\1/")

echo "$major_version.$minor_version.$patch_version"
