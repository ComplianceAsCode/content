#!/bin/bash
#
# profiles = xccdf_org.ssgproject.content_profile_stig-rhel7-disa

yum install -y chrony
yum remove -y ntp

if ! grep "^server.*maxpoll 10" /etc/chrony.conf; then
    sed -i "s/^server.*/&1 maxpoll 10/" /etc/chrony.conf
fi

echo "server test.ntp.org" >> /etc/chrony.conf

systemctl enable chronyd.service
