#!/bin/bash
# platform = multi_platform_all

# Create binaries with wrong permissions (0755)
touch /usr/bin/at
touch /usr/bin/atq
touch /usr/bin/atrm
touch /usr/bin/batch
chmod 0755 /usr/bin/at
chmod 0755 /usr/bin/atq
chmod 0755 /usr/bin/atrm
chmod 0755 /usr/bin/batch
