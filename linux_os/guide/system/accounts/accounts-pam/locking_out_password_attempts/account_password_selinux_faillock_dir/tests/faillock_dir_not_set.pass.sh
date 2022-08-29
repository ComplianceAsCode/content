#!/bin/bash
# packages = policycoreutils-python-utils
# platform = multi_platform_all

PAM_FILES="/etc/pam.d/password-auth /etc/pam.d/system-auth"
truncate -s 0 /etc/security/faillock.conf
sed -i --follow-symlinks -E 's/(\h*auth\b.*\bpam_faillock\.so\b.*)dir=.*/\1/g' $PAM_FILES
