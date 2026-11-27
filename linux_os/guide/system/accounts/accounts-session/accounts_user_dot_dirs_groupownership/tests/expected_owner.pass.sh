#!/bin/bash
# platform = multi_platform_debian,multi_platform_ubuntu
# packages = linux-base

USER="cac_user"
useradd -m $USER
mkdir -p /home/$USER/.config
chgrp -R "$(id -g $USER)" /home/$USER/.config
