#!/bin/bash

USER="cac_user"
useradd -m -s /sbin/nologin $USER
echo "umask 022" >> /home/$USER/.bashrc
