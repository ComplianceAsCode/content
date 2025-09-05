#!/bin/bash

AUTH_FILES[0]="/etc/pam.d/system-auth"
{{%- if product == "rhel7" %}}
AUTH_FILES[1]="/etc/pam.d/password-auth"
{{%- endif %}}

for pamFile in "${AUTH_FILES[@]}"
do
	if ! grep -q "^password.*sufficient.*pam_unix.so.*sha512" $pamFile; then
		sed -i --follow-symlinks "/^password.*sufficient.*pam_unix.so/ s/$/ sha512/" $pamFile
	fi
done
