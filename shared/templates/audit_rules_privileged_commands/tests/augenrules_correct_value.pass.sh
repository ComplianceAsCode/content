#!/bin/bash
# Writes the exact audit rules the check requires; the scan must pass.

source common.sh

{{% if product in ["fedora", "rhel10"] %}}
echo "-a always,exit -F arch=b32 -F path={{{ PATH }}} ${perm_x} -F auid>={{{ auid }}} -F auid!=unset -k test_key" >> /etc/audit/rules.d/test_key.rules
echo "-a always,exit -F arch=b64 -F path={{{ PATH }}} ${perm_x} -F auid>={{{ auid }}} -F auid!=unset -k test_key" >> /etc/audit/rules.d/test_key.rules
{{% elif product == "rhel9" and RHEL9_STIG_ARCH_MODE %}}
echo "-a always,exit -F arch=b32{{% if RHEL9_STIG_EXECVE %}} -S execve{{% endif %}} -F path={{{ PATH }}} ${perm_x} -k {{{ KEY }}}" >> /etc/audit/rules.d/identity.rules
echo "-a always,exit -F arch=b64{{% if RHEL9_STIG_EXECVE %}} -S execve{{% endif %}} -F path={{{ PATH }}} ${perm_x} -k {{{ KEY }}}" >> /etc/audit/rules.d/identity.rules
{{% else %}}
{{% if REQUIRE_KEY %}}
echo "-a always,exit -F path={{{ PATH }}} ${perm_x} -F auid>={{{ auid }}} -F auid!=unset -k {{{ KEY }}}" >> /etc/audit/rules.d/test_key.rules
{{% else %}}
echo "-a always,exit -F path={{{ PATH }}} ${perm_x} -F auid>={{{ auid }}} -F auid!=unset -k test_key" >> /etc/audit/rules.d/test_key.rules
{{% endif %}}
{{% endif %}}
