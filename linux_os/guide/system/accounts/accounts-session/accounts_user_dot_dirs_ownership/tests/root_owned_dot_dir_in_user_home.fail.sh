#!/bin/bash
# platform = multi_platform_debian
# packages = linux-base

USER="cac_user"
useradd -m $USER
mkdir -p /home/$USER/.cache
chown 0 /home/$USER/.cache
