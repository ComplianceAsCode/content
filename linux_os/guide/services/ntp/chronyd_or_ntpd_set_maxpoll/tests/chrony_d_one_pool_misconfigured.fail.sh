#!/bin/bash
# packages = chrony
# variables = var_time_service_set_maxpoll=16
# platform = multi_platform_rhel

{{{ bash_package_remove("ntp") }}}

# Remove all server or pool options
sed -i "/^\(server\|pool\).*/d" {{{ chrony_d_path }}}/20-pools.conf

echo "pool pool.ntp.org iburst maxpoll 18" >> {{{ chrony_d_path }}}/20-pools.conf

systemctl enable chronyd.service

