#!/bin/bash
# packages = audit
source common.sh

sed -i "s%^ExecStartPost=.*%ExecStartPost=-/sbin/auditctl%" /usr/lib/systemd/system/auditd.service

echo "-a always,exit -F path={{{ PATH }}} ${perm_x} -k test_key" >> /etc/audit/audit.rules
