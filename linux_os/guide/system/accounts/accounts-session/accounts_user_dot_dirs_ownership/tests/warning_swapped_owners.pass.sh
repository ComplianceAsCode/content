#!/bin/bash

# Documents the limitation recorded in the rule's warnings block: a dot directory
# belonging to one interactive user but ownered by another still passes, because the
# check only requires an interactive user's id.
USER1="cac_user1"
USER2="cac_user2"
useradd -m $USER1
useradd -m $USER2
mkdir -p /home/$USER1/.config
chown -R $USER2 /home/$USER1/.config
