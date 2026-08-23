#!/bin/bash

USER="cac_user"
useradd -m $USER
echo "$USER" > /home/$USER/$USER.txt
find "/home/$USER/" -perm /7027 -exec chmod u-s,g-w-s,o=- {} \;
