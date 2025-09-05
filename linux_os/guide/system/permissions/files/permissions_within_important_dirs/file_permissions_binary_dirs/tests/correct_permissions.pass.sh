#!/bin/bash

DIRS="/bin /usr/bin /usr/local/bin /sbin /usr/sbin /usr/local/sbin /usr/libexec"
for dirPath in $DIRS; do
    find "$dirPath" -perm /022 -type f -exec chmod 0755 '{}' \;
done
