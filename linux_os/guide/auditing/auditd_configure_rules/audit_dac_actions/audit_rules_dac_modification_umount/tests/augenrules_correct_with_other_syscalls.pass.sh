#!/bin/bash
# packages = audit

rm -f /etc/audit/rules.d/*
> /etc/audit/audit.rules

echo "-a always,exit -F arch=b32 -S umount,umount2 -F auid>={{{ uid_min }}} -F auid!=unset -F key=perm_mod" >> /etc/audit/rules.d/perm_mod.rules
