#!/bin/bash
# packages = /usr/lib/systemd/system/sssd.service

SSSD_CONF="/etc/sssd/sssd.conf"
TIMEOUT="180"

systemctl enable sssd
mkdir -p /etc/sssd
touch $SSSD_CONF
echo -e "[ssh]\nsomething = wrong\n[pam]\nssh_known_hosts_timeout = $TIMEOUT" >> $SSSD_CONF
