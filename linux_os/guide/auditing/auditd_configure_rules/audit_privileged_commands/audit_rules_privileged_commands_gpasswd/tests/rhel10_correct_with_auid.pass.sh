#!/bin/bash
# platform = Red Hat Enterprise Linux 10
# packages = audit

{{{ setup_auditctl_environment() }}}

# The RHEL 10 check accepts the arch-split rules with the auid filters as
# well; the filters are optional the same way the RHEL 9 benchmark's SCAP
# accepts them
echo "-a always,exit -F arch=b32 -F path=/usr/bin/gpasswd -F auid>={{{ auid }}} -F auid!=unset -F perm=x -k test_key" >> /etc/audit/audit.rules
echo "-a always,exit -F arch=b64 -F path=/usr/bin/gpasswd -F auid>={{{ auid }}} -F auid!=unset -F perm=x -k test_key" >> /etc/audit/audit.rules
