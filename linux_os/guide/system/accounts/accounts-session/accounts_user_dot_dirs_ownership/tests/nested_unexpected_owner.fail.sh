#!/bin/bash
# platform = multi_platform_debian,multi_platform_ubuntu
# packages = linux-base

USER="cac_user"
useradd -m $USER
mkdir -p /home/$USER/src/project/.git
chown -R $USER /home/$USER/src
chown 2 /home/$USER/src/project/.git
