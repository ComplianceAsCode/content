#!/bin/bash
# platform = multi_platform_rhel,multi_platform_ol

rm -f /etc/pam.d/postlogin

cat <<EOF > /etc/pam.d/postlogin
#%PAM-1.0
# This file is auto-generated.
# User changes will be destroyed the next time authconfig is run.


session     [success=1 default=ignore] pam_succeed_if.so service !~ gdm* service !~ su* quiet
session     [default=1]   pam_lastlog.so nowtmp showfailed
session     optional      pam_lastlog.so silent noupdate showfailed
EOF
