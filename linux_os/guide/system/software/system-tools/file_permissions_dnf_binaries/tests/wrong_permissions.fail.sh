#!/bin/bash
# platform = multi_platform_all

# Create binaries with wrong permissions (0755)
touch /usr/bin/dnf
touch /usr/bin/dnf-3
touch /usr/bin/yum
chmod 0755 /usr/bin/dnf
chmod 0755 /usr/bin/dnf-3
chmod 0755 /usr/bin/yum
