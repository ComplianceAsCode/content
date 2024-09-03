#!/bin/bash
# packages = audit

{{{ setup_auditctl_environment() }}}

echo "-a always,exit -F dir=/var/log/auditd/ -F perm=r -F auid>={{{ uid_min }}} -F auid!=unset -F key=access-audit-trail" >> /etc/audit/audit.rules
