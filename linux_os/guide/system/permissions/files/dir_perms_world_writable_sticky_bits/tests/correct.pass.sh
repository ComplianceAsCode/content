#!/bin/bash

# Perform remediation
df --local -P | awk '{if (NR!=1) print $6}' \
| xargs -I '$6' find '$6' -xdev -type d \
\( -perm -0002 -a ! -perm -1000 \) 2>/dev/null \
-exec chmod a+t {} +

# Create a new dir that has sticky bit but is not word-writable
mkdir -p /test_dir_1
chmod 1770 /test_dir_1

# Create a new dir that is word-readable and doesn't have sticky bit
mkdir -p /test_dir_2
chmod 0774 /test_dir_2
