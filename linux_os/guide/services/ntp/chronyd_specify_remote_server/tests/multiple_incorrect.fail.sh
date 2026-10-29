#!/bin/bash
# packages = chrony
# platform = multi_platform_ubuntu
# remediation = None

rm -rf /etc/chrony/conf.d
rm -rf /etc/chrony/sources.d

echo "server 0.pool.ntp.org" > {{{ chrony_conf_path }}}
echo "server 0.ubuntu.pool.ntp.org" >> {{{ chrony_conf_path }}}
