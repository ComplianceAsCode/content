#!/bin/bash
# platform = multi_platform_ubuntu

USER="cac_user"
useradd -m $USER
mkdir -p /home/$USER/src/project/.git
chgrp -R "$(id -g $USER)" /home/$USER/src
chgrp 2 /home/$USER/src/project/.git
