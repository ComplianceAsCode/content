#!/bin/bash
# packages = /usr/lib/systemd/system/sssd.service
#

rm -rf /etc/sssd/conf.d/
SSSD_CONF="/etc/sssd/sssd.conf"
cp wrong_sssd.conf $SSSD_CONF
