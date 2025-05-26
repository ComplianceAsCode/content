#!/bin/bash
# packages = audit

{{{ setup_auditctl_environment() }}}

echo "-a always,exit -F arch=b32 -F dir=/var/log/audit/ -F perm=r -F auid>={{{ uid_min }}} -F auid!=unset -F key=access-audit-trail" >> /etc/audit/audit.rules
echo "-a always,exit -F arch=b64 -F dir=/var/log/audit/ -F perm=r -F auid>={{{ uid_min }}} -F auid!=unset -F key=access-audit-trail" >> /etc/audit/audit.rules
