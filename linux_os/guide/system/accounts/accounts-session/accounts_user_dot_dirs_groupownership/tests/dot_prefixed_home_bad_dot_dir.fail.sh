#!/bin/bash
# platform = multi_platform_debian
# packages = linux-base

# Dot directories below a home directory whose name starts with a dot are
# still checked.
USER="cac_user"
useradd -m -d /home/.$USER $USER
mkdir -p /home/.$USER/.cache
chgrp 0 /home/.$USER/.cache
