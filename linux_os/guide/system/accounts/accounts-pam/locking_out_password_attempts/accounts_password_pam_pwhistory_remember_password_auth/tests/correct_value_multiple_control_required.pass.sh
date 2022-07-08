#!/bin/bash
# packages = pam
# platforms = Oracle Linux 8
# profiles = xccdf_org.ssgproject.content_profile_stig

{{{ bash_package_remove("authselect") }}}

config_file="/etc/pam.d/password-auth"

sed -i --follow-symlinks "/pam_pwhistory\.so/d" $config_file

echo "password required pam_pwhistory.so use_authtok remember=5 retry=3" >> $config_file
