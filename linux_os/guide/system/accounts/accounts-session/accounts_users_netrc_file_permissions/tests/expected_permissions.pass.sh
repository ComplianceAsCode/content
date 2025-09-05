#!/bin/bash

USER="cac_user"
useradd -m $USER
echo "$USER" > /home/$USER/.netrc
chmod -f 0600 /home/$USER/.netrc
