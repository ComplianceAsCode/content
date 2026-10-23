#!/bin/bash

source common.sh

{{% if product == "rhel10" and RHEL10_STIG_ARCH_MODE %}}
echo "-a always,exit -F arch=b32{{% if RHEL10_STIG_EXECVE %}} -S execve{{% endif %}} -F path={{{ PATH }}} ${perm_x} -k {{{ KEY }}}" >> /etc/audit/rules.d/{{{ KEY }}}.rules
echo "-a always,exit -F arch=b64{{% if RHEL10_STIG_EXECVE %}} -S execve{{% endif %}} -F path={{{ PATH }}} ${perm_x} -k {{{ KEY }}}" >> /etc/audit/rules.d/{{{ KEY }}}.rules
{{% elif product in ["fedora", "rhel10"] and not REQUIRE_KEY %}}
echo "-a always,exit -F arch=b32 -F path={{{ PATH }}} ${perm_x} -F auid>={{{ auid }}} -F auid!=unset -k test_key" >> /etc/audit/rules.d/test_key.rules
echo "-a always,exit -F arch=b64 -F path={{{ PATH }}} ${perm_x} -F auid>={{{ auid }}} -F auid!=unset -k test_key" >> /etc/audit/rules.d/test_key.rules
{{% else %}}
{{% if REQUIRE_KEY %}}
echo "-a always,exit -F path={{{ PATH }}} ${perm_x} -F auid>={{{ auid }}} -F auid!=unset -k {{{ KEY }}}" >> /etc/audit/rules.d/test_key.rules
{{% else %}}
echo "-a always,exit -F path={{{ PATH }}} ${perm_x} -F auid>={{{ auid }}} -F auid!=unset -k test_key" >> /etc/audit/rules.d/test_key.rules
{{% endif %}}
{{% endif %}}
