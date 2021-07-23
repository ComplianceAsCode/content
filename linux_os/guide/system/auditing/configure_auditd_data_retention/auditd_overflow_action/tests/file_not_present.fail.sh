#!/bin/bash

config_file=/etc/audit/auditd.conf

if [[ -f $config_file ]]; then
    rm -f $config_file
fi
