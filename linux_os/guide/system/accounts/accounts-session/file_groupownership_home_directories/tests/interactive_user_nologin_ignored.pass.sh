#!/bin/bash

USER="cac_user"
useradd -m -s /sbin/nologin $USER
chgrp 10005 /home/$USER
