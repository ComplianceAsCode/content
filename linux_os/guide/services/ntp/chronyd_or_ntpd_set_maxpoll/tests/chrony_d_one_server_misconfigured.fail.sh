#!/bin/bash
# packages = chrony
# variables = var_time_service_set_maxpoll=16

{{{ bash_package_remove("ntp") }}}

# Remove all pool options
sed -i "/^pool.*/d" {{{ chrony_d_path }}}/10-servers.conf

if ! grep "^server.*maxpoll 10" {{{ chrony_d_path }}}/10-servers.conf ; then
    sed -i "s/^server.*/& maxpoll 10/" {{{ chrony_d_path }}}/10-servers.conf
fi

echo "server test.ntp.org" >> {{{ chrony_d_path }}}/10-servers.conf

systemctl enable chronyd.service
