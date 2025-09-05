#!/bin/bash

USER="cac_user"
useradd -m $USER
chmod -f g-w+s,o=t /home/$USER
