#!/bin/bash

USER="cac_user"
useradd -m -s /sbin/nologin $USER
echo "$USER" > /home/$USER/$USER.txt
chgrp 10005 /home/$USER/$USER.txt
