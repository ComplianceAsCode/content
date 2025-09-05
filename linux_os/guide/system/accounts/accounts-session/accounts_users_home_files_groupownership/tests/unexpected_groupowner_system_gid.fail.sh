#!/bin/bash

USER="cac_user"
useradd -m $USER
echo "$USER" > /home/$USER/$USER.txt
chgrp 2 /home/$USER/$USER.txt
