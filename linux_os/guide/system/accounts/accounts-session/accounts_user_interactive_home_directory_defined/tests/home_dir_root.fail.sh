#!/bin/bash

USER="cac_user"
useradd -M $USER

sed -i "s/\($USER:x:[0-9]*:[0-9]*:.*:\).*\(:.*\)$/\1\/\2/g" /etc/passwd
