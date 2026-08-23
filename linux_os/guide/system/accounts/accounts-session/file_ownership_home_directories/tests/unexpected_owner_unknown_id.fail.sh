#!/bin/bash

USER="cac_user"
useradd -m $USER
chown 10005 /home/$USER
