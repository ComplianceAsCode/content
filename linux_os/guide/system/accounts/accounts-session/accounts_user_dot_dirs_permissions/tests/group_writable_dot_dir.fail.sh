#!/bin/bash
# platform = multi_platform_ubuntu

USER="cac_user"
useradd -m $USER
mkdir -p /home/$USER/.config
chmod 0770 /home/$USER/.config
