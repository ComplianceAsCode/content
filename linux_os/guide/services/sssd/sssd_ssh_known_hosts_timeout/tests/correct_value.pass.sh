#!/bin/bash
# packages = /usr/lib/systemd/system/sssd.service

# profiles = xccdf_org.ssgproject.content_profile_ospp

SSSD_CONF="/etc/sssd/sssd.conf"
# The smallest variable value for sssd_memcache_timeout is 180 so
# this should pass for every product which contains ospp profile
TIMEOUT="180"

systemctl enable sssd
mkdir -p /etc/sssd
touch $SSSD_CONF
echo -e "[ssh]\nssh_known_hosts_timeout = $TIMEOUT" >> $SSSD_CONF
