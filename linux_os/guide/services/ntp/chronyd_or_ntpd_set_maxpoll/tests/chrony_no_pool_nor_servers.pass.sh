#!/bin/bash
# packages = chrony
#
# profiles = xccdf_org.ssgproject.content_profile_stig

yum remove -y ntp

# Remove all pool and server options
sed -i "/^pool.*/d" {{{ chrony_conf_path }}}
sed -i "/^server.*/d" {{{ chrony_conf_path }}}

systemctl enable chronyd.service
