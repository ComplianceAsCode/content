#!/bin/bash
# packages = chrony
# variables = var_time_service_set_maxpoll=16

{{{ bash_package_remove("ntp") }}}

# Remove all pool options
sed -i "/^pool.*/d" {{{ chrony_conf_path }}}

if ! grep "^server" {{{ chrony_conf_path }}} ; then
    echo "server foo.example.net iburst maxpoll 10" >> {{{ chrony_conf_path }}}
elif ! grep "^server.*maxpoll 10" {{{ chrony_conf_path }}}; then
    sed -i "s/^server.*/& maxpoll 10/" {{{ chrony_conf_path }}}
fi

systemctl enable chronyd.service
