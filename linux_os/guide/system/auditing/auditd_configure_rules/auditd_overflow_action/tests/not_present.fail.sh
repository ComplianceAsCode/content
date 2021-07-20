#!/bin/bash
config_file=/etc/audit/auditd.conf

test -d /etc/audit/ || mkdir -p /etc/audit/

if [[ -f $config_file ]]; then
    sed -i "s/^.*overflow_action.*$//" $config_file
else
    touch $config_file
fi
