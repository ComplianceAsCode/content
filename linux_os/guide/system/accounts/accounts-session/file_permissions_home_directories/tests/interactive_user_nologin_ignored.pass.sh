#!/bin/bash

USER="cac_user"
useradd -m -s /sbin/nologin $USER
chmod 755 /home/$USER
