#!/bin/bash
# packages = ntp
#
# profiles = xccdf_org.ssgproject.content_profile_stig
# platform = Red Hat Enterprise Linux 7

yum remove -y chrony

sed -i "s/^server.*/& maxpoll 17/" /etc/ntp.conf

systemctl enable ntpd.service

# The remediation configures ntp only if ntpd is running
systemctl start ntpd.service
