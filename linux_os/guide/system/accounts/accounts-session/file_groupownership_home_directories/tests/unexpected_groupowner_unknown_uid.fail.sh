#!/bin/bash

USER="cac_user"
useradd -m $USER
chgrp 10005 /home/$USER
