#!/bin/bash
# platform = multi_platform_debian
# packages = linux-base

# Only directories below the home directory are checked, not a home directory
# whose name starts with a dot.
USER="cac_user"
useradd -m -d /home/.$USER $USER
chown 0 /home/.$USER
