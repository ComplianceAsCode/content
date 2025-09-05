#!/bin/bash

USER="cac_user"
useradd -m $USER
echo "$USER" > /home/$USER/$USER.txt
chmod -f o+w /home/$USER/$USER.txt
