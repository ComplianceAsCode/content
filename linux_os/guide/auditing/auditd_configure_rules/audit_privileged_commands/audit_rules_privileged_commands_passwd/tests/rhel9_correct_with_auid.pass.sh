#!/bin/bash
# platform = Red Hat Enterprise Linux 9
# packages = audit

{{{ setup_auditctl_environment() }}}

# The RHEL 9 check accepts the arch-split rules with the v2R9-era auid filters
# as well; DISA's SCAP benchmark makes the filters optional
echo "-a always,exit -F arch=b32 -F path=/usr/bin/passwd -F auid>={{{ auid }}} -F auid!=unset -F perm=x -k test_key" >> /etc/audit/audit.rules
echo "-a always,exit -F arch=b64 -F path=/usr/bin/passwd -F auid>={{{ auid }}} -F auid!=unset -F perm=x -k test_key" >> /etc/audit/audit.rules
