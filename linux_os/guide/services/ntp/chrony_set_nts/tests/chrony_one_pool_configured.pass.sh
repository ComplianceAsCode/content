#!/bin/bash
# packages = chrony

{{{ bash_package_remove("ntp") }}}

# Remove all server or pool options
sed -i "/^\(server\|pool\).*/d" {{{ chrony_conf_path }}}

echo "pool pool.ntp.org iburst nts" >> {{{ chrony_conf_path }}}

systemctl enable chronyd.service

