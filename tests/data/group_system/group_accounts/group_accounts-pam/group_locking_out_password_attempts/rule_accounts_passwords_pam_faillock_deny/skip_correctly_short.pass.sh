#!/bin/bash
#
# profiles = xccdf_org.ssgproject.content_profile_C2S

cp pam_config_skip_correctly_short /etc/pam.d/system-auth
cp pam_config_skip_correctly_short /etc/pam.d/password-auth
