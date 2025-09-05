#!/bin/bash
# platform = multi_platform_fedora,multi_platform_ol,multi_platform_rhel,multi_platform_sle,multi_platform_slmicro,multi_platform_ubuntu
# packages = audit

source common.sh

{{{ setup_auditctl_environment() }}}

echo "-a always,exit -F path={{{ PATH }}} -F auid>={{{ auid }}} -F auid!=unset -k test_key" \
>> /etc/audit/audit.rules
