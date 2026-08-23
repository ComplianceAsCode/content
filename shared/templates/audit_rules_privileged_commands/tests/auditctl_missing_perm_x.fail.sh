#!/bin/bash
# platform = multi_platform_fedora,multi_platform_ol,multi_platform_rhel,multi_platform_sle,multi_platform_slmicro,multi_platform_ubuntu,multi_platform_almalinux
# packages = audit

source common.sh

{{{ setup_auditctl_environment() }}}

{{% if product in ["fedora", "rhel10"] %}}
echo "-a always,exit -F arch=b32 -F path={{{ PATH }}} -F auid>={{{ auid }}} -F auid!=unset -k test_key" >> /etc/audit/audit.rules
echo "-a always,exit -F arch=b64 -F path={{{ PATH }}} -F auid>={{{ auid }}} -F auid!=unset -k test_key" >> /etc/audit/audit.rules
{{% else %}}
echo "-a always,exit -F path={{{ PATH }}} -F auid>={{{ auid }}} -F auid!=unset -k test_key" >> /etc/audit/audit.rules
{{% endif %}}
