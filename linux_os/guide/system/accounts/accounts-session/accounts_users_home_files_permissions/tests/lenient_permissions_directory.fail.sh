#!/bin/bash

USER="cac_user"
useradd -m "${USER}"
mkdir -p /home/"${USER}"/folder
chmod -Rf 700 /home/"${USER}"/.*
chmod -f o+r /home/"${USER}"/folder
