#!/bin/bash
# remediation = none

USER="cac_user"
useradd -m $USER
mkdir -p /home/$USER/.ssh
chmod 0755 /home/$USER/.ssh
