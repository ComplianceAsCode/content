#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_C2S, xccdf_org.ssgproject.content_profile_ospp

SELINUX_FILE='/etc/selinux/config'
sed -i '/^[[:space:]]*SELINUXTYPE/d' $SELINUX_FILE
