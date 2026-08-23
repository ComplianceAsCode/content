#!/bin/bash
# packages = sssd
#

rm -rf /etc/sssd/conf.d/
SSSD_CONF="/etc/sssd/sssd.conf"
cp wrong_sssd.conf $SSSD_CONF
