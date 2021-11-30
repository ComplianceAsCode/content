#!/bin/bash

USER="cac_user"
useradd -m $USER
chgrp $USER /home/$USER
