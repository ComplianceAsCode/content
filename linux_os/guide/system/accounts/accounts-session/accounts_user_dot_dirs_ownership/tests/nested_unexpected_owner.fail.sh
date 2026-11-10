#!/bin/bash
# platform = multi_platform_ubuntu

USER="cac_user"
useradd -m $USER
mkdir -p /home/$USER/src/project/.git
chown -R $USER /home/$USER/src
chown 2 /home/$USER/src/project/.git
