#!/bin/bash
# packages = chrony
#
# profiles = xccdf_org.ssgproject.content_profile_stig

yum remove -y ntp

# Remove all pool options
sed -i "/^pool.*/d" {{{ chrony_conf_path }}}

if ! grep "^server" {{{ chrony_conf_path }}} ; then
    echo "server foo.example.net iburst maxpoll 10" >> {{{ chrony_conf_path }}}
elif ! grep "^server.*maxpoll 10" {{{ chrony_conf_path }}}; then
    sed -i "s/^server.*/& maxpoll 10/" {{{ chrony_conf_path }}}
fi

systemctl enable chronyd.service
