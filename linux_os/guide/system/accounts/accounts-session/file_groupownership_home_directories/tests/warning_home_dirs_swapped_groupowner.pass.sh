#!/bin/bash

USER1="cac_user1"
USER2="cac_user2"

useradd -m $USER1
useradd -m $USER2
# Swap the group-ownership of two home directories
# WARNING: This test scenario will report a false negative, as explained in the
# warning section of this rule.
chgrp $USER2 /home/$USER1
chgrp $USER1 /home/$USER2
