#!/bin/bash
# packages = ntp
#
# profiles = xccdf_org.ssgproject.content_profile_stig
# platform = Oracle Linux 7,Red Hat Enterprise Linux 7

{{{ bash_package_remove("chrony") }}}

sed -i "s/^server.*/& maxpoll 17/" /etc/ntp.conf

systemctl enable ntpd.service

# The remediation configures ntp only if ntpd is running
systemctl start ntpd.service
