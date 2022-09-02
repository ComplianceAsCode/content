#!/bin/bash
# packages = chrony
# platform = multi_platform_fedora,multi_platform_ol,multi_platform_rhel

sed -i "^pool.*" {{{ chrony_conf_path }}}
echo "server 0.pool.ntp.org" > {{{ chrony_conf_path }}}
