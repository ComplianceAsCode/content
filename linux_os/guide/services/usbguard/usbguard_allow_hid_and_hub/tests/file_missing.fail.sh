#!/bin/bash
#
# profiles = xccdf_org.ssgproject.content_profile_ospp

source $SHARED/utils.sh

get_packages usbguard

rm -f /etc/usbguard/rules.conf
