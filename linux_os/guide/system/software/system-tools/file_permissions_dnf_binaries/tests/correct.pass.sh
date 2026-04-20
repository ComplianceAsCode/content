#!/bin/bash
# platform = multi_platform_all

# Create binaries with correct permissions (0000)
touch /usr/bin/dnf
touch /usr/bin/dnf-3
touch /usr/bin/yum
chmod 0000 /usr/bin/dnf
chmod 0000 /usr/bin/dnf-3
chmod 0000 /usr/bin/yum
