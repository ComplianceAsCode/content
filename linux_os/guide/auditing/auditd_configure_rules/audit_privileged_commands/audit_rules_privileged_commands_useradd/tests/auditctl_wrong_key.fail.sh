#!/bin/bash
# platform = Red Hat Enterprise Linux 8,Red Hat Enterprise Linux 9,Red Hat Enterprise Linux 10
# packages = audit

{{{ setup_auditctl_environment() }}}

echo "-a always,exit -F path=/usr/sbin/useradd -F perm=x -F auid>={{{ uid_min }}} -F auid!=unset -F key=wrong" >> /etc/audit/audit.rules
