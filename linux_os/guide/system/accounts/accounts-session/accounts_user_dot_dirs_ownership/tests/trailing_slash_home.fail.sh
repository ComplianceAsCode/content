#!/bin/bash
# platform = multi_platform_debian
# packages = linux-base

# The home directory in /etc/passwd ends with a slash.
USER="cac_user"
useradd -m -d /home/$USER/ $USER
mkdir -p /home/$USER/.cache
chown 0 /home/$USER/.cache
