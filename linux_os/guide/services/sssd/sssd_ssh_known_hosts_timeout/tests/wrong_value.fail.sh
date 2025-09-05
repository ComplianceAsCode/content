#!/bin/bash
# packages = /usr/lib/systemd/system/sssd.service

# profiles = xccdf_org.ssgproject.content_profile_ospp

SSSD_CONF="/etc/sssd/sssd.conf"

# The rule sssd_memcache_timeout requires memcache_timeout = 86400
# Let's put there a different value to fail
TIMEOUT="99999"

systemctl enable sssd
mkdir -p /etc/sssd
touch $SSSD_CONF
echo -e "[ssh]\nssh_known_hosts_timeout = $TIMEOUT" >> $SSSD_CONF
