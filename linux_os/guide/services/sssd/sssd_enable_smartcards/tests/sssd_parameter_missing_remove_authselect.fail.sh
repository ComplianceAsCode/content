#!/bin/bash
# packages = sssd
rm -rf /usr/bin/authselect
SSSD_FILE="/etc/sssd/sssd.conf"
rm -f $SSSD_FILE
