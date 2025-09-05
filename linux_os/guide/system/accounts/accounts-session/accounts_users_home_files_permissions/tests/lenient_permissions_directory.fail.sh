#!/bin/bash

USER="cac_user"
useradd -m $USER
mkdir /home/$USER/folder
chmod -Rf 700 /home/$USER/.*
chmod -f o+r /home/$USER/folder
