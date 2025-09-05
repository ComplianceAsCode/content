#!/bin/bash

USER1="cac_user1"
USER2="cac_user2"

useradd -m $USER1
useradd -m $USER2
touch /home/$USER1/.bashrc
touch /home/$USER2/.bashrc

# Swap the ownership of files in two home directories
# WARNING: This test scenario will report a false negative, as explained in the
# warning section of this rule.
GROUP1=$(id $USER1 -g)
GROUP2=$(id $USER2 -g)
chgrp -f $GROUP2 /home/$USER1/.bashrc
chgrp -f $GROUP1 /home/$USER2/.bashrc

