#!/bin/bash
# packages = chrony
#
# profiles = xccdf_org.ssgproject.content_profile_stig

yum remove -y ntp

if ! grep "^server" /etc/chrony.conf ; then
    echo "server foo.example.net iburst maxpoll 10" >> /etc/chrony.conf
elif ! grep "^server.*maxpoll 10" /etc/chrony.conf; then
    sed -i "s/^server.*/& maxpoll 10/" /etc/chrony.conf
fi

systemctl enable chronyd.service
