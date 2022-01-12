#!/bin/bash

DIRS="/bin /usr/bin /usr/local/bin /sbin /usr/sbin /usr/local/sbin /usr/libexec"
for dirPath in $DIRS; do
    find "$dirPath" -type f -exec chmod 0777 '{}' \;
done
