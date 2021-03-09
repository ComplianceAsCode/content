#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_stig

AUTH_FILES[0]="/etc/pam.d/system-auth"
AUTH_FILES[1]="/etc/pam.d/password-auth"

for pamFile in "${AUTH_FILES[@]}"
do
	if grep -q ".*pwhistory\.so.*remember=" $pamFile; then
		sed -i -E --follow-symlinks "s/(^password.*pam_pwhistory\.so.*)(remember\s*=\s*[0-9]+)(.*$)/\1remember=5 \3/" $pamFile
	elif grep -q ".*pwhistory\.so.*" $pamFile; then
		sed -i --follow-symlinks "/^password[[:space:]]\+.*[[:space:]]\+pam_pwhistory\.so/ s/$/ remember=5/" $pamFile
	else
		sed -i -E --follow-symlinks '0,/^password/s/(^password.*)/\1\npassword requisite pam_pwhistory.so remember=5/' $pamFile
	fi
done
