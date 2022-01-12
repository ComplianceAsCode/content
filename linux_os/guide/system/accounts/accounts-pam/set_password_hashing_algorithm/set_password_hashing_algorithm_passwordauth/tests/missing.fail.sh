#!/bin/bash

sed -i --follow-symlinks "/^password.*sufficient.*pam_unix.so/ s/sha512//g" "/etc/pam.d/password-auth"
