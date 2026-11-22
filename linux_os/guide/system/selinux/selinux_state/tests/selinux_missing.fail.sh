#!/bin/bash
# profiles = C2S, ospp
# remediation = none

SELINUX_FILE='/etc/selinux/config'
touch "$SELINUX_FILE"
sed -i '/^[[:space:]]*SELINUX/d' $SELINUX_FILE
