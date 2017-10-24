#!/bin/bash
#
# profiles = xccdf_org.ssgproject.content_profile_stig-rhel7-disa

yum install -y ntp
yum remove -y chrony

if ! grep "^server.*maxpoll 10" /etc/ntp.conf; then
    sed -i "s/^server.*/&1 maxpoll 10/" /etc/ntp.conf
fi

systemctl enable ntpd.service
systemctl start ntpd.service
