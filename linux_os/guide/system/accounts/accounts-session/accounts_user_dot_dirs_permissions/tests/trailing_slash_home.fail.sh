#!/bin/bash
# platform = multi_platform_debian
# packages = linux-base

# The home directory in /etc/passwd ends with a slash.
USER="cac_user"
useradd -m -d /home/$USER/ $USER
mkdir -p /home/$USER/.cache
chmod 0777 /home/$USER/.cache
