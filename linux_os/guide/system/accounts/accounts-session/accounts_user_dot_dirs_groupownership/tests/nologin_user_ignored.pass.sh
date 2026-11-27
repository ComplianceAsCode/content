#!/bin/bash
# platform = multi_platform_debian
# packages = linux-base

# Users whose shell is nologin are not local interactive users.
USER="cac_nologin"
useradd -m -s /usr/sbin/nologin $USER
mkdir -p /home/$USER/.config
chgrp -R 2 /home/$USER/.config
