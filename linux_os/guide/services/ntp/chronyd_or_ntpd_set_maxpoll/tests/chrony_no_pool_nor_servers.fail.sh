#!/bin/bash
# packages = chrony
# remediation = none
# variables = var_time_service_set_maxpoll=16

{{{ bash_package_remove("ntp") }}}

# Remove all pool and server options
sed -i "/^pool.*/d" {{{ chrony_conf_path }}}
sed -i "/^server.*/d" {{{ chrony_conf_path }}}

systemctl enable chronyd.service
