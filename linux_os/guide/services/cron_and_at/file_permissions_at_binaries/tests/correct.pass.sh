#!/bin/bash
# platform = multi_platform_all

# Create binaries with correct permissions (0000)
touch /usr/bin/at
touch /usr/bin/atq
touch /usr/bin/atrm
touch /usr/bin/batch
chmod 0000 /usr/bin/at
chmod 0000 /usr/bin/atq
chmod 0000 /usr/bin/atrm
chmod 0000 /usr/bin/batch
