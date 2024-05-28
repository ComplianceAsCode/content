#!/bin/bash
# packages = chrony
# variables = var_time_service_set_maxpoll=16

{{{ bash_package_remove("ntp") }}}

# Remove all server options
sed -i "/^\(server\|pool\).*/d" {{{ chrony_conf_path }}}

echo "pool pool.ntp.org iburst" >> {{{ chrony_conf_path }}}

systemctl enable chronyd.service

