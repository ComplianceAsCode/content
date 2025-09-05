#!/bin/bash

USER="cac_user"
useradd -m $USER
chgrp 2 /home/$USER
