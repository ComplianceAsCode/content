#!/bin/bash

USER="cac_user"
useradd -m $USER
touch /home/$USER/nodotfile
chown 2 /home/$USER/nodotfile
