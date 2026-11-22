#!/bin/bash
# profiles = C2S, ospp
# remediation = none

SELINUX_FILE='/etc/selinux/config'
sed -i '/^[[:space:]]*SELINUX/d' $SELINUX_FILE
