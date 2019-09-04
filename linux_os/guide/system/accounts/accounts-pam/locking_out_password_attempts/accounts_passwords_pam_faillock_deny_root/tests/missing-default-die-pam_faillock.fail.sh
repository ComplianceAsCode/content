#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_cui, xccdf_org.ssgproject.content_profile_ospp
. set-up-pamd.sh

set-up-pamd
sed -i '/auth[[:space:]]*\[default=die\][[:space:]]*pam_faillock\.so.*even_deny_root/d' /etc/pam.d/password-auth
