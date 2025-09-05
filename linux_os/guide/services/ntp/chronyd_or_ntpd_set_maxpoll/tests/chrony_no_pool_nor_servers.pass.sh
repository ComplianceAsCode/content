#!/bin/bash
# packages = chrony
#
# profiles = xccdf_org.ssgproject.content_profile_stig

{{{ bash_package_remove("ntp") }}}

# Remove all pool and server options
sed -i "/^pool.*/d" {{{ chrony_conf_path }}}
sed -i "/^server.*/d" {{{ chrony_conf_path }}}

systemctl enable chronyd.service
