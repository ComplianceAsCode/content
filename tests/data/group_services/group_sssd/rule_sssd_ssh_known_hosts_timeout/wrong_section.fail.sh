#!/bin/bash

# profiles = xccdf_org.ssgproject.content_profile_ospp

SSSD_CONF="/etc/sssd/sssd.conf"
TIMEOUT="180"

yum -y install /usr/lib/systemd/system/sssd.service
systemctl enable sssd
mkdir -p /etc/sssd
touch $SSSD_CONF
echo -e "[ssh]\nsomething = wrong\n[pam]\nssh_known_hosts_timeout = $TIMEOUT" >> $SSSD_CONF
