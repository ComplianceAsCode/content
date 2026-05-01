#!/bin/bash
# platform = multi_platform_all

# Create binaries with wrong permissions (0755)
touch /usr/bin/ncat
touch /usr/bin/nc
chmod 0755 /usr/bin/ncat
chmod 0755 /usr/bin/nc
