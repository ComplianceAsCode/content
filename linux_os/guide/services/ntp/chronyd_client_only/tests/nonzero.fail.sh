#!/bin/bash
#
# profiles = xccdf_org.ssgproject.content_profile_ospp

yum install -y chrony
systemctl enable chronyd.service

echo "port 124" >> /etc/chrony.conf
