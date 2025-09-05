#!/bin/bash

USER1="cac_user1"
USER2="cac_user2"

useradd -m $USER1
useradd -M $USER2

# Make sure no umask definition exists in the startup files
sed -i 's/^\([\s]*umask\s*\)/#\1/g' /home/$USER1/.[^\.]?*
