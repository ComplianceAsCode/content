#!/bin/bash
# platform = Ubuntu 26.04

USER1="cac_user1"
USER2="cac_user2"
useradd -m $USER1
useradd -m $USER2
mkdir -p /home/$USER1/.config
chgrp -R "$(id -g $USER2)" /home/$USER1/.config
