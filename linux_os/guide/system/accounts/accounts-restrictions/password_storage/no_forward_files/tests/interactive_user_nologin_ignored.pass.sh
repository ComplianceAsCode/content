#!/bin/bash
# remediation = none

USER="cac_user"
useradd -m -s /sbin/nologin $USER
touch /home/$USER/.forward
