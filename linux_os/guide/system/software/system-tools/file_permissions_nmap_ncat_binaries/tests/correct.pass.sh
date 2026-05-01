#!/bin/bash
# platform = multi_platform_all

# Create binaries with correct permissions (0000)
touch /usr/bin/ncat
touch /usr/bin/nc
chmod 0000 /usr/bin/ncat
chmod 0000 /usr/bin/nc
