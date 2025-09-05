#!/bin/bash

USER="cac_user"
useradd -M $USER

sed -i 's/\(.*:x:[0-9]\{4,\}:[0-9]*:.*:\).*\(:.*\)$/\1\/tmp\2/g' /etc/passwd
