#!/bin/bash
# remediation = none

USER="cac_user"
useradd -m $USER
mkdir -p /home/$USER/.config
chown -R 2 /home/$USER/.config
