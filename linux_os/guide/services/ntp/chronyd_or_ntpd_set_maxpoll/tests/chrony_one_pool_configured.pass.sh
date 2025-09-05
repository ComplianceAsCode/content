#!/bin/bash
# packages = chrony
#
# profiles = xccdf_org.ssgproject.content_profile_stig

yum remove -y ntp

# Remove all server or pool options
sed -i "/^\(server\|pool\).*/d" {{{ chrony_conf_path }}}

echo "pool pool.ntp.org iburst maxpoll 16" >> {{{ chrony_conf_path }}}

systemctl enable chronyd.service

