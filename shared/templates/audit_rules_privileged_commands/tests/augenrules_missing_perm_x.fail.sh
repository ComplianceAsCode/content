#!/bin/bash
# platform = multi_platform_fedora,multi_platform_ol,multi_platform_rhel,multi_platform_sle,multi_platform_slmicro,multi_platform_ubuntu,multi_platform_almalinux

source common.sh

echo "-a always,exit -F path={{{ PATH }}} -F auid>={{{ auid }}} -F auid!=unset -k test_key" \
>> /etc/audit/rules.d/test_key.rules
