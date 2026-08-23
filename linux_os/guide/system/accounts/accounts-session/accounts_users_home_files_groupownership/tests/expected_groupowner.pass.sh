#!/bin/bash

USER="cac_user"
useradd -m $USER
echo "$USER" > /home/$USER/$USER.txt
GROUP=$(id $USER -g)
chgrp -f $GROUP /home/$USER/$USER.txt

