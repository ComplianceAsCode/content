#!/bin/bash

USER="cac_user"
useradd -m $USER
touch /home/$USER/.bashrc
chmod -f o+w /home/$USER/.bashrc
