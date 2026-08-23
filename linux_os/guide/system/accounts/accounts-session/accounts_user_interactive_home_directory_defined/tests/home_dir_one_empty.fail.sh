#!/bin/bash

USER1="cac_user1"
USER2="cac_user2"
useradd -M $USER1
useradd -M $USER2

sed -i "s/\($USER1:x:[0-9]*:[0-9]*:.*:\).*\(:.*\)$/\1\2/g" /etc/passwd
