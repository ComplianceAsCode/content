#!/bin/bash
# packages = chrony
#
# profiles = xccdf_org.ssgproject.content_profile_stig

yum remove -y ntp

if ! grep "^server.*maxpoll 10" /etc/chrony.conf; then
    sed -i "s/^server.*/& maxpoll 10/" /etc/chrony.conf
fi

echo "server test.ntp.org" >> /etc/chrony.conf

systemctl enable chronyd.service
