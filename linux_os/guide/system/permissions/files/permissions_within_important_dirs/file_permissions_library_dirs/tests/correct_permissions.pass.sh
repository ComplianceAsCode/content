#!/bin/bash

DIRS="/lib /lib64 /usr/lib /usr/lib64"
for dirPath in $DIRS; do
    chmod -R 755 "$dirPath"
done
