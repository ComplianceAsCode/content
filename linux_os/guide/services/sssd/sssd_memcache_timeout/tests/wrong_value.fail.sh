#!/bin/bash
# packages = /usr/lib/systemd/system/sssd.service

SSSD_CONF="/etc/sssd/sssd.conf"

# The highest variable value for sssd_memcache_timeout is 86400 so
# Let's put there a higher value to fail
TIMEOUT="99999"

systemctl enable sssd
mkdir -p /etc/sssd
touch $SSSD_CONF
echo -e "[nss]\nmemcache_timeout = $TIMEOUT" >> $SSSD_CONF
