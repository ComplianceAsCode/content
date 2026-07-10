#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_cis
# platform = multi_platform_all

SSHD_CONFIG="{{{ sshd_main_config_file }}}"

if grep -q "^MaxSessions" $SSHD_CONFIG; then
    sed -i "s/^MaxSessions.*/MaxSessions 61/" $SSHD_CONFIG
else
    echo "MaxSessions 61" >> $SSHD_CONFIG
fi
