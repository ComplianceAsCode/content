#!/bin/bash

USER="cac_user"
useradd -m -s /sbin/nologin $USER
chmod 753 /home/$USER
