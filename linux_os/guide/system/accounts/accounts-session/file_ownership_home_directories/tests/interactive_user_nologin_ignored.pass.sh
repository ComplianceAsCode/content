#!/bin/bash

USER="cac_user"
useradd -m -s /sbin/nologin $USER
chown 10005 /home/$USER
