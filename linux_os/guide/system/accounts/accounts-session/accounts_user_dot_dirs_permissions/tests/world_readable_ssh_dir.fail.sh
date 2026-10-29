#!/bin/bash
# platform = multi_platform_ubuntu

USER="cac_user"
useradd -m $USER
mkdir -p /home/$USER/.ssh
chmod 0755 /home/$USER/.ssh
