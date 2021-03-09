#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_stig

AUTH_FILES[0]="/etc/pam.d/system-auth"
AUTH_FILES[1]="/etc/pam.d/password-auth"

AUTH_FILES[0]="/etc/pam.d/system-auth"
AUTH_FILES[1]="/etc/pam.d/password-auth"

for pamFile in "${AUTH_FILES[@]}"
do
	if grep -q ".*unix\.so.*remember=" $pamFile; then
		sed -i -E --follow-symlinks "s/(^password.*pam_unix\.so.*)(remember\s*=\s*[0-9]+)(.*$)/\1remember=1 \3/" $pamFile
	elif grep -q ".*unix\.so.*" $pamFile; then
		sed -i --follow-symlinks "/^password[[:space:]]\+.*[[:space:]]\+pam_unix\.so/ s/$/ remember=1/" $pamFile
	else
		sed -i -E --follow-symlinks '0,/^password/s/(^password.*)/\1\npassword sufficient pam_unix.so remember=1/' $pamFile
	fi
done
