#!/bin/bash
# packages = ntp
#
# profiles = xccdf_org.ssgproject.content_profile_stig
# platform = Oracle Linux 7,Red Hat Enterprise Linux 7

yum remove -y chrony

sed -i "s/^server.*/& maxpoll 17/" /etc/ntp.conf
echo "server 0.test.ntp.org maxpoll 17 iburst" >> /etc/ntp.conf
echo "server 1.test.ntp.org maxpoll 17 iburst" >> /etc/ntp.conf
echo "server 2.test.ntp.org maxpoll 17 iburst" >> /etc/ntp.conf
echo "server 3.test.ntp.org" >> /etc/ntp.conf
echo "server 4.test.ntp.org" >> /etc/ntp.conf
echo "server 5.test.ntp.org" >> /etc/ntp.conf
echo "server 6.test.ntp.org maxpoll 16 iburst" >> /etc/ntp.conf

systemctl enable ntpd.service

# The remediation configures ntp only if ntpd is running
systemctl start ntpd.service

