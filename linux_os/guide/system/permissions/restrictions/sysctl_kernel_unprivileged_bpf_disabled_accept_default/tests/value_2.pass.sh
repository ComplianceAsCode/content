#!/bin/bash
# platform = Red Hat Enterprise Linux 9,multi_platform_fedora

{{{ bash_sysctl_test_clean() }}}

sed -i "/kernel.unprivileged_bpf_disabled/d" /etc/sysctl.conf
echo "kernel.unprivileged_bpf_disabled = 2" >> /etc/sysctl.conf

# set correct runtime value to check if the filesystem configuration is evaluated properly
sysctl -w kernel.unprivileged_bpf_disabled="2"
