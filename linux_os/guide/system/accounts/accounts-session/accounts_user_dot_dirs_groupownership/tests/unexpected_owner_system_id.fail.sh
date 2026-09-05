#!/bin/bash
# remediation = none

USER="cac_user"
useradd -m $USER
mkdir -p /home/$USER/.config
chgrp -R 2 /home/$USER/.config
