#!/bin/bash
# platform = multi_platform_ubuntu

USER="cac_user"
useradd -m $USER
mkdir -p /home/$USER/.config
chgrp -R "$(id -g $USER)" /home/$USER/.config
