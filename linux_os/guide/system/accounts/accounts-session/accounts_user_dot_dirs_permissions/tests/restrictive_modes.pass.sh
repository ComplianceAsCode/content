#!/bin/bash

USER="cac_user"
useradd -m $USER
mkdir -p /home/$USER/.config /home/$USER/.ssh
chmod 0750 /home/$USER/.config
chmod 0700 /home/$USER/.ssh
