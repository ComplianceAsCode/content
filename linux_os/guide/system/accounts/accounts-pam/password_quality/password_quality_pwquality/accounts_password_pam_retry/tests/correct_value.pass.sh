#!/bin/bash

# profiles = xccdf_org.ssgproject.content_profile_ospp

retry_cnt=3
config_file="/etc/pam.d/system-auth"

if grep -q "pam_pwquality\.so.*retry=" "$config_file" ; then
	sed -i --follow-symlinks "/pam_pwquality\.so/ s/\(retry *= *\).*/\1$retry_cnt/" $config_file
else
	sed -i --follow-symlinks "/pam_pwquality\.so/ s/$/ retry=$retry_cnt/" $config_file
fi
