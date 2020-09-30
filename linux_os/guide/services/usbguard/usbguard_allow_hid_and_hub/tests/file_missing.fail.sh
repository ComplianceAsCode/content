#!/bin/bash
#

source $SHARED/utils.sh

get_packages usbguard

rm -f /etc/usbguard/rules.conf
