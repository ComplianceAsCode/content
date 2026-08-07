#!/bin/bash
# packages = audit

{{{ setup_auditctl_environment() }}}

rm -f /etc/audit/rules.d/*
> /etc/audit/audit.rules

echo "-a always,exit -F arch=b32 -S umount -F auid>={{{ uid_min }}} -F auid!=unset -F key=perm_mod" >> /etc/audit/audit.rules
