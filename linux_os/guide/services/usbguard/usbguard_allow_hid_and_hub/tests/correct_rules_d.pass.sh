#!/bin/bash
#

source $SHARED/utils.sh

get_packages usbguard

echo "allow with-interface match-all { 03:*:* }" >> /etc/usbguard/rules.d/30-hid-and-hub.conf
