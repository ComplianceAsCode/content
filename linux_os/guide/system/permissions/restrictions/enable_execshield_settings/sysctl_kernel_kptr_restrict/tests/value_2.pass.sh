#!/bin/bash
# platform = multi_platform_fedora,multi_platform_ol,multi_platform_rhel

{{{ bash_sysctl_test_clean() }}}

sed -i "/kernel.kptr_restrict/d" /etc/sysctl.conf
echo "kernel.kptr_restrict = 2" >> /etc/sysctl.conf

# set correct runtime value to check if the filesystem configuration is evaluated properly
sysctl -w kernel.kptr_restrict="2"
