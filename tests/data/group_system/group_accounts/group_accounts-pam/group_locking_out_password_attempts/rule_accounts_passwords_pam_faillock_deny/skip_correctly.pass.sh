#!/bin/bash
#
# profiles = xccdf_org.ssgproject.content_profile_ospp

cp pam_config_skip_correctly /etc/pam.d/system-auth
cp pam_config_skip_correctly /etc/pam.d/password-auth
