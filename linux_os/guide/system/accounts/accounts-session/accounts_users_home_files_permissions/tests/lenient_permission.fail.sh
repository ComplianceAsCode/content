#!/bin/bash

USER="cac_user"
useradd -m $USER
echo "$USER" > /home/$USER/$USER.txt
chmod -Rf 700 /home/$USER/.*
chmod -f o+r /home/$USER/$USER.txt
