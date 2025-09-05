#!/bin/bash

USER="cac_user"
useradd -m $USER
touch /home/$USER/.bashrc
chown $USER /home/$USER/.bashrc
