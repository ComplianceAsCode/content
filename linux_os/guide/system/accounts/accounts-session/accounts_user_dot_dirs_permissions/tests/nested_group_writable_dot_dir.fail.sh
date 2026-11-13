#!/bin/bash
# platform = multi_platform_ubuntu

USER="cac_user"
useradd -m $USER
mkdir -p /home/$USER/src/project/.git
chmod 0775 /home/$USER/src/project/.git
