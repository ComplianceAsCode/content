#!/bin/bash
# packages = ntp
# variables = var_time_service_set_maxpoll=16
# platform = Oracle Linux 7,Red Hat Enterprise Linux 7

{{{ bash_package_remove("chrony") }}}

sed -i "s/^server.*/& maxpoll 17/" /etc/ntp.conf

systemctl enable ntpd.service

# The remediation configures ntp only if ntpd is running
systemctl start ntpd.service
