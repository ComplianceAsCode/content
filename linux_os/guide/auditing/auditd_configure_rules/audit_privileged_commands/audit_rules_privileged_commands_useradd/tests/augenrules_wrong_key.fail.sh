#!/bin/bash
# packages = audit
# platform = Red Hat Enterprise Linux 8,Red Hat Enterprise Linux 9

rm -f /etc/audit/rules.d/*.rules
truncate -s 0 /etc/audit/audit.rules

echo "-a always,exit -F path=/usr/sbin/useradd -F perm=x -F auid>={{{ uid_min }}} -F auid!=unset -F key=wrong" >> /etc/audit/rules.d/useradd.rules
