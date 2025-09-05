#!/bin/bash

USER="cac_user"
useradd -m $USER
echo "$USER" > /home/$USER/.netrc
chmod 0660 /home/$USER/.netrc
