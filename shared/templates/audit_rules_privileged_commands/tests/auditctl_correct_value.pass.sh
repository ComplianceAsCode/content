#!/bin/bash
# packages = audit
# Writes the exact audit rules the check requires; the scan must pass.
source common.sh

{{{ setup_auditctl_environment() }}}

{{% if product == "rhel10" and RHEL10_STIG_ARCH_MODE %}}
echo "-a always,exit -F arch=b32{{% if RHEL10_STIG_EXECVE %}} -S execve{{% endif %}} -F path={{{ PATH }}} ${perm_x} -k {{{ KEY }}}" >> /etc/audit/audit.rules
echo "-a always,exit -F arch=b64{{% if RHEL10_STIG_EXECVE %}} -S execve{{% endif %}} -F path={{{ PATH }}} ${perm_x} -k {{{ KEY }}}" >> /etc/audit/audit.rules
{{% elif product == "rhel9" and RHEL9_STIG_ARCH_MODE %}}
echo "-a always,exit -F arch=b32{{% if RHEL9_STIG_EXECVE %}} -S execve{{% endif %}} -F path={{{ PATH }}} ${perm_x} -k {{{ KEY }}}" >> /etc/audit/audit.rules
echo "-a always,exit -F arch=b64{{% if RHEL9_STIG_EXECVE %}} -S execve{{% endif %}} -F path={{{ PATH }}} ${perm_x} -k {{{ KEY }}}" >> /etc/audit/audit.rules
{{% elif product in ["fedora", "rhel10"] and not REQUIRE_KEY %}}
echo "-a always,exit -F arch=b32 -F path={{{ PATH }}} ${perm_x} -F auid>={{{ auid }}} -F auid!=unset -k test_key" >> /etc/audit/audit.rules
echo "-a always,exit -F arch=b64 -F path={{{ PATH }}} ${perm_x} -F auid>={{{ auid }}} -F auid!=unset -k test_key" >> /etc/audit/audit.rules
{{% else %}}
{{% if REQUIRE_KEY %}}
echo "-a always,exit -F path={{{ PATH }}} ${perm_x} -F auid>={{{ auid }}} -F auid!=unset -k {{{ KEY }}}" >> /etc/audit/audit.rules
{{% else %}}
echo "-a always,exit -F path={{{ PATH }}} ${perm_x} -F auid>={{{ auid }}} -F auid!=unset -k test_key" >> /etc/audit/audit.rules
{{% endif %}}
{{% endif %}}
