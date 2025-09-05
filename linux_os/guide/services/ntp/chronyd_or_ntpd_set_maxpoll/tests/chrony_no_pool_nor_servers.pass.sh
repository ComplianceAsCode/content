#!/bin/bash
# packages = chrony
#
# profiles = xccdf_org.ssgproject.content_profile_stig

yum remove -y ntp

# Remove all pool and server options
sed -i "/^pool.*/d" /etc/chrony.conf
sed -i "/^server.*/d" /etc/chrony.conf

systemctl enable chronyd.service
