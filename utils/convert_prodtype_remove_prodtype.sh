#!/bin/sh

guides="linux_os/guide \
products/chromium/guide \
applications \
products/firefox/guide \
apple_os"

script=$(realpath "$0")
root=$(dirname "$script")

for path in $guides; do
  find "$root/../$path" -type f -print0 | xargs -0 sed -i "/prodtype:/d"
done
