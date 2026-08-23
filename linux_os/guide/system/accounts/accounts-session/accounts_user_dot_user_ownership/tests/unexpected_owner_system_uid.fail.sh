#!/bin/bash

USER="cac_user"
useradd -m $USER
touch /home/$USER/.bashrc
chown 2 /home/$USER/.bashrc
