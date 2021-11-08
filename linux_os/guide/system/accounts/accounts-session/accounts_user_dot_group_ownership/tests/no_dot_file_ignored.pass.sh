#!/bin/bash

USER="cac_user"
useradd -m $USER
touch /home/$USER/nodotfile
chgrp 2 /home/$USER/nodotfile
