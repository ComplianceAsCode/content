#!/bin/bash

USER="cac_user"
useradd -m $USER
touch /home/$USER/.bashrc
chgrp $USER /home/$USER/.bashrc
