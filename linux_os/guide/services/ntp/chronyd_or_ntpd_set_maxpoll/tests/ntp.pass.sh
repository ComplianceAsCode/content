#!/bin/bash
# packages = ntp
#
# profiles = xccdf_org.ssgproject.content_profile_stig
# platform = Red Hat Enterprise Linux 7

yum remove -y chrony

if ! grep "^server.*maxpoll 10" /etc/ntp.conf; then
    sed -i "s/^server.*/& maxpoll 10/" /etc/ntp.conf
fi

systemctl enable ntpd.service
systemctl start ntpd.service
