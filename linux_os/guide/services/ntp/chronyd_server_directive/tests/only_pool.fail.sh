#!/bin/bash
# packages = chrony
# platform = multi_platform_fedora,multi_platform_ol,multi_platform_rhel
# remediation = none

sed -i "^server.*" {{{ chrony_conf_path }}}
if ! grep "^pool.*" {{{ chrony_conf_path }}}; then
    echo "pool 0.pool.ntp.org" > {{{ chrony_conf_path }}}
fi
