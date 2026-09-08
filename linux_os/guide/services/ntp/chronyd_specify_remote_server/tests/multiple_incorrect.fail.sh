#!/bin/bash
# packages = chrony
# platform = Ubuntu 22.04,Ubuntu 24.04
# remediation = None

rm -rf /etc/chrony/conf.d
rm -rf /etc/chrony/sources.d

echo "server 0.pool.ntp.org" > {{{ chrony_conf_path }}}
echo "server 0.ubuntu.pool.ntp.org" >> {{{ chrony_conf_path }}}
