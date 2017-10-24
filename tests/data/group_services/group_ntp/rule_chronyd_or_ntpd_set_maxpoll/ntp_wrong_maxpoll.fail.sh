#!/bin/bash
#
# profiles = xccdf_org.ssgproject.content_profile_stig-rhel7-disa

yum install -y ntp
yum remove -y chrony

sed -i "s/^server.*/&1 maxpoll 17/" /etc/ntp.conf

systemctl enable ntpd.service
systemctl start ntpd.service
