#!/bin/bash
# packages = chrony
#
# profiles = xccdf_org.ssgproject.content_profile_stig

{{{ bash_package_remove("ntp") }}}

# Remove all server options
sed -i "/^\(server\|pool\).*/d" {{{ chrony_conf_path }}}

echo "pool pool.ntp.org iburst" >> {{{ chrony_conf_path }}}

systemctl enable chronyd.service

