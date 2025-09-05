#!/bin/bash
# packages = chrony
#
# profiles = xccdf_org.ssgproject.content_profile_stig

yum remove -y ntp

# Remove all server options
sed -i "/^\(server\|pool\).*/d" /etc/chrony.conf

echo "pool pool.ntp.org iburst" >> /etc/chrony.conf

systemctl enable chronyd.service

