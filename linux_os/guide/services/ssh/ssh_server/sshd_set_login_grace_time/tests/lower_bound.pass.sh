#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_cis,xccdf_org.ssgproject.content_profile_pci-dss-4
# platform = multi_platform_all

SSHD_CONFIG="{{{ sshd_main_config_file }}}"

if grep -q "^LoginGraceTime" $SSHD_CONFIG; then
        sed -i "s/^LoginGraceTime.*/LoginGraceTime 1/" $SSHD_CONFIG
    else
        echo "LoginGraceTime 1" >> $SSHD_CONFIG
fi
