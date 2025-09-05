#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_cis
# platform = multi_platform_all

SSHD_CONFIG="/etc/ssh/sshd_config"

if grep -q "^MaxSessions" $SSHD_CONFIG; then
        sed -i "s/^MaxSessions.*/MaxSessions 0/" $SSHD_CONFIG
    else
        echo "MaxSessions 0" >> $SSHD_CONFIG
fi
