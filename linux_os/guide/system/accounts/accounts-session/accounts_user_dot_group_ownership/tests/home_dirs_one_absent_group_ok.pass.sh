#!/bin/bash

USER1="cac_user1"
USER2="cac_user2"

useradd -m $USER1
useradd -M $USER2

touch /home/$USER1/.bashrc
GROUP=$(id $USER1 -g)
chgrp -f $GROUP /home/$USER1/.bashrc
