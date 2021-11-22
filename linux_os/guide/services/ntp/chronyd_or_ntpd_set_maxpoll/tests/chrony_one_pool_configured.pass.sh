#!/bin/bash
# packages = chrony
#
# profiles = xccdf_org.ssgproject.content_profile_stig

yum remove -y ntp

# Remove all server or pool options
sed -i "/^\(server\|pool\).*/d" /etc/chrony.conf

echo "pool pool.ntp.org iburst maxpoll 16" >> /etc/chrony.conf

systemctl enable chronyd.service

