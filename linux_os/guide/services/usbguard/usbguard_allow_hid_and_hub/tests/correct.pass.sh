#!/bin/bash
#
# profiles = xccdf_org.ssgproject.content_profile_ospp

source $SHARED/utils.sh

get_packages usbguard

echo "allow with-interface match-all { 03:*:* }" >> /etc/usbguard/rules.conf
