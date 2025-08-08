#!/bin/bash

USER="cac_user"
useradd -m $USER
GROUP=$(id $USER -g)
chgrp $GROUP /home/$USER

