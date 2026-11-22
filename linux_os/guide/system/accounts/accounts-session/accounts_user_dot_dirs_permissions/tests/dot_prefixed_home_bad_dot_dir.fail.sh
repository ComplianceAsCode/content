#!/bin/bash
# platform = multi_platform_debian
# packages = linux-base

# Dot directories below a home directory whose name starts with a dot are
# still checked.
USER="cac_user"
useradd -m -d /home/.$USER $USER
mkdir -p /home/.$USER/.cache
chmod 0777 /home/.$USER/.cache
