#!/bin/bash
# packages = chrony
# platform = multi_platform_ubuntu
# remediation = None

echo "server 0.pool.ntp.org" > {{{ chrony_conf_path }}}
echo "server 0.ubuntu.pool.ntp.org" >> {{{ chrony_conf_path }}}
