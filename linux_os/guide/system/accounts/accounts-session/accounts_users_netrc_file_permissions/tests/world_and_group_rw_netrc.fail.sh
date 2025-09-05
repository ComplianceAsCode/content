#!/bin/bash

USER="cac_user"
useradd -m $USER
echo "$USER" > /home/$USER/.netrc
chmod 0666 /home/$USER/.netrc
