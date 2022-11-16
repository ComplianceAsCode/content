#!/bin/bash

USER="cac_user"
useradd -m $USER
echo "umask 022" > /home/$USER/.bash_history
