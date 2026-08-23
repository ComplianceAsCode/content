#!/bin/bash

USER="cac_user"
useradd -m $USER
echo "$USER" > /home/$USER/$USER.txt
touch /home/$USER/$(printf "evil_filename_\334_non_utf8_character")
chown $USER /home/$USER/*
