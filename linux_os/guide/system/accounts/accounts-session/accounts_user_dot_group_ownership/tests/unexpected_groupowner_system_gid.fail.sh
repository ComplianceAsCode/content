#!/bin/bash

USER="cac_user"
useradd -m $USER
touch /home/$USER/.bashrc
chgrp 2 /home/$USER/.bashrc
