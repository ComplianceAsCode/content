#!/bin/bash
# packages = chrony
# variables = var_time_service_set_maxpoll=16
# platform = multi_platform_rhel,multi_platform_fedora,multi_platform_ol,multi_platform_sle

{{{ bash_package_remove("ntp") }}}

# Remove the /etc/chrony.d directory to simulate systems where it doesn't exist
# (e.g., ppc64le systems with chrony-dhcp in Testing Farm)
rm -rf {{{ chrony_d_path }}}

# Configure maxpoll correctly in the main chrony.conf file
sed -i "/^\(server\|pool\).*/d" {{{ chrony_conf_path }}}
echo "pool pool.ntp.org iburst maxpoll 16" >> {{{ chrony_conf_path }}}
echo "server time.nist.gov maxpoll 16" >> {{{ chrony_conf_path }}}

systemctl enable chronyd.service
