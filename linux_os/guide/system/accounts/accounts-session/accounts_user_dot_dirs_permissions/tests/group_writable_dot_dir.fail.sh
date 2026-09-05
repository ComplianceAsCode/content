#!/bin/bash
# platform = Ubuntu 26.04

USER="cac_user"
useradd -m $USER
mkdir -p /home/$USER/.config
chmod 0770 /home/$USER/.config
