#!/bin/bash
# packages = audit
# Writes the exact audit rules the check requires; the scan must pass.
source common.sh

{{{ setup_auditctl_environment() }}}

{{% if product == "rhel10" and RHEL10_STIG_ARCH_MODE %}}
echo "-a always,exit -F arch=b32 -F path={{{ PATH }}} ${perm_x} -k {{{ KEY }}}" >> /etc/audit/audit.rules
echo "-a always,exit -F arch=b64 -F path={{{ PATH }}} ${perm_x} -k {{{ KEY }}}" >> /etc/audit/audit.rules
{{% elif product in ["fedora", "rhel10", "ol10"] and not RHEL10_STIG_SINGLE_RULE %}}
echo "-a always,exit -F arch=b32 -F path={{{ PATH }}} ${perm_x} -F auid>={{{ auid }}} -F auid!=unset -k test_key" >> /etc/audit/audit.rules
echo "-a always,exit -F arch=b64 -F path={{{ PATH }}} ${perm_x} -F auid>={{{ auid }}} -F auid!=unset -k test_key" >> /etc/audit/audit.rules
{{% else %}}
echo "-a always,exit -F path={{{ PATH }}} ${perm_x} -F auid>={{{ auid }}} -F auid!=unset -k test_key" >> /etc/audit/audit.rules
{{% endif %}}
