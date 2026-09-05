#!/bin/bash
# remediation = none

USER="cac_user"
useradd -m $USER
mkdir -p /home/$USER/.config
chmod 0770 /home/$USER/.config
