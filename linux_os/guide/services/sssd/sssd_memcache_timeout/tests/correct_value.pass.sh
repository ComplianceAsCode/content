#!/bin/bash
# packages = /usr/lib/systemd/system/sssd.service

SSSD_CONF="/etc/sssd/sssd.conf"
# The smallest variable value for sssd_memcache_timeout is 180 so
# this should pass for every product which contains ospp profile
TIMEOUT="180"

systemctl enable sssd
mkdir -p /etc/sssd
touch $SSSD_CONF
echo -e "[nss]\nmemcache_timeout = $TIMEOUT" >> $SSSD_CONF
