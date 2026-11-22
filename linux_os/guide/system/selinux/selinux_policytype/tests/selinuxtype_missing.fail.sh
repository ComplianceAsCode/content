#!/bin/bash
# profiles = C2S, ospp

SELINUX_FILE='/etc/selinux/config'
sed -i '/^[[:space:]]*SELINUXTYPE/d' $SELINUX_FILE
