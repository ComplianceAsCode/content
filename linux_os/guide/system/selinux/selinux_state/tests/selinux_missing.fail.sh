#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_C2S, xccdf_org.ssgproject.content_profile_ospp
# remediation = none

SELINUX_FILE='/etc/selinux/config'
touch "$SELINUX_FILE"
sed -i '/^[[:space:]]*SELINUX/d' $SELINUX_FILE
