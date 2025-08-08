#!/bin/bash

USER1="cac_user1"
USER2="cac_user2"

useradd -m $USER1
useradd -m $USER2
# Define the same owner for two home directories
GROUP1=$(id $USER1 -g)
chgrp $GROUP1 /home/$USER1
chgrp $GROUP1 /home/$USER2
