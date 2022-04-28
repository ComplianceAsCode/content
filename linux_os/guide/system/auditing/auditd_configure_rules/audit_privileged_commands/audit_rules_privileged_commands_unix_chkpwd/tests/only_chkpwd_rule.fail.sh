#!/bin/bash
# packages = audit

echo "-a always,exit -F path=/sbin/unix_chkpwd -F perm=x -F auid>=1000 -F auid!=unset -F key=privileged" >> /etc/audit/rules.d/privileged.rules
