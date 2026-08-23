#!/bin/bash

USER="cac_user"
useradd -m $USER
touch /home/$USER/.bashrc
GROUP=$(id $USER -g)
chgrp -f $GROUP /home/$USER/.bashrc
