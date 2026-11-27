#!/bin/bash
# platform = multi_platform_debian
# packages = linux-base

# Dot directories on another filesystem mounted below the home directory are
# not checked.
USER="cac_user"
useradd -m $USER
mkdir -p /home/$USER/data
mount -t tmpfs cac_tmpfs /home/$USER/data || exit 1
mkdir -p /home/$USER/data/.cache
chown 0 /home/$USER/data/.cache
