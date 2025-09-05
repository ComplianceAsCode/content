#!/bin/bash
# platform = multi_platform_fedora,multi_platform_ol,multi_platform_rhel,multi_platform_sle,multi_platform_ubuntu

source common.sh

sed -i "s%^ExecStartPost=.*%ExecStartPost=-/sbin/augenrules%" /usr/lib/systemd/system/auditd.service

echo "-a always,exit -F path={{{ PATH }}} -F auid>={{{ auid }}} -F auid!=unset -k test_key" \
>> /etc/audit/rules.d/test_key.rules
