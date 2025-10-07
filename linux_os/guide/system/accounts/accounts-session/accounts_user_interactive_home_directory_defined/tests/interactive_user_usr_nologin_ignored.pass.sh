#!/bin/bash

USER="cac_user"
useradd -m -s /usr/sbin/nologin $USER
sed -i "s/\($USER:x:[0-9]*:[0-9]*:.*:\).*\(:.*\)$/\1\2/g" /etc/passwd
