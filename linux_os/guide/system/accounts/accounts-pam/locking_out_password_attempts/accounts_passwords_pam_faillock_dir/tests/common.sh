#!/bin/bash

pam_files=("password-auth" "system-auth")

authselect create-profile testingProfile --base-on minimal

CUSTOM_PROFILE_DIR="/etc/authselect/custom/testingProfile"

for file in ${pam_files[@]}; do
	if grep -q "pam_faillock\.so.*dir=" "$CUSTOM_PROFILE_DIR/$file" ; then
		sed -i --follow-symlinks "/pam_faillock\.so/d" "$CUSTOM_PROFILE_DIR/$file"
	fi
done

authselect select --force custom/testingProfile

truncate -s 0 /etc/security/pam_faillock.conf
