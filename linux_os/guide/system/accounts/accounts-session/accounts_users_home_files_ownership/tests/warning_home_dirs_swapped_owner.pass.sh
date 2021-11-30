#!/bin/bash

USER1="cac_user1"
USER2="cac_user2"

useradd -m $USER1
useradd -m $USER2
echo "$USER1" > /home/$USER1/$USER1.txt
echo "$USER2" > /home/$USER2/$USER2.txt
# Swap the ownership of files in two home directories
# WARNING: This test scenario will report a false negative, as explained in the
# warning section of this rule.
chown -f $USER2 /home/$USER1/$USER1.txt
chown -f $USER1 /home/$USER2/$USER2.txt
