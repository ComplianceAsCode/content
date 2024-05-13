#!/bin/bash
# packages = ntp
# variables = var_time_service_set_maxpoll=16
# platform = Oracle Linux 7,Red Hat Enterprise Linux 7

{{{ bash_package_remove("chrony") }}}

if ! grep "^server.*maxpoll 10" /etc/ntp.conf; then
    sed -i "s/^server.*/& maxpoll 10/" /etc/ntp.conf
fi

systemctl enable ntpd.service
systemctl start ntpd.service
