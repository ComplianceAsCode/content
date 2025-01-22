#!/bin/bash

USER="cac_user"
useradd -m $USER
mkdir -p /home/"${USER}"/folder
echo "umask 022" > /home/"${USER}"/folder/.bashrc
