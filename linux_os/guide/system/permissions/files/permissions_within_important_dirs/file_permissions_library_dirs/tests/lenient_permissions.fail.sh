#!/bin/bash

DIRS="/lib /lib64 /usr/lib /usr/lib64"
for dirPath in $DIRS; do
    find "$dirPath" -type f -exec chmod go+w '{}' \;
done
