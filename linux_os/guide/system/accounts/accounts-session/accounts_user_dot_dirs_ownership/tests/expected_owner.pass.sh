#!/bin/bash
# platform = Ubuntu 26.04

USER="cac_user"
useradd -m $USER
mkdir -p /home/$USER/.config
chown -R $USER /home/$USER/.config
