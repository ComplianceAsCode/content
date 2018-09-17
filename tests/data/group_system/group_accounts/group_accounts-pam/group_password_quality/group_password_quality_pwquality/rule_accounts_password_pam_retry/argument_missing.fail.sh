#!/bin/bash

# profiles = xccdf_org.ssgproject.content_profile_ospp

config_file="/etc/pam.d/system-auth"

if grep -q "pam_pwquality\.so.*retry=" "$config_file" ; then
	sed -i --follow-symlinks "/pam_pwquality\.so/ s/\(retry *= *\).*//" $config_file
fi
