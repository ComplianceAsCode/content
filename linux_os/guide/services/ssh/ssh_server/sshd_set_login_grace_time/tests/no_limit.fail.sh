#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_cis
# platform = multi_platform_all

SSHD_CONFIG="/etc/ssh/sshd_config"

if grep -q "^LoginGraceTime" $SSHD_CONFIG; then
        sed -i "s/^LoginGraceTime.*/LoginGraceTime 0/" $SSHD_CONFIG
    else
        echo "LoginGraceTime 0" >> $SSHD_CONFIG
fi
