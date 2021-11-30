#!/bin/bash

USER="cac_user"
useradd -m $USER
echo "$USER" > /home/$USER/$USER.txt
chgrp -f $USER /home/$USER/$USER.txt
