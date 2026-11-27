#!/bin/bash
# platform = multi_platform_debian,multi_platform_ubuntu
# packages = linux-base

USER="cac_user"
useradd -m $USER
mkdir -p /home/$USER/.config /home/$USER/.ssh
chmod 0750 /home/$USER/.config
chmod 0700 /home/$USER/.ssh
