#!/bin/bash

AUTH_FILES[0]="/etc/pam.d/system-auth"
AUTH_FILES[1]="/etc/pam.d/password-auth"

for pamFile in "${AUTH_FILES[@]}"
do
	sed -i --follow-symlinks "/^password.*sufficient.*pam_unix.so/ s/sha512//g" $pamFile
done
