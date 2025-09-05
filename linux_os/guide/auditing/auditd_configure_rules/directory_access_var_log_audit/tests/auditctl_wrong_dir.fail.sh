#!/bin/bash
# packages = audit


# Use auditctl in RHEL7
sed -i "s%^ExecStartPost=.*%ExecStartPost=-/sbin/auditctl%" /usr/lib/systemd/system/auditd.service

echo "-a always,exit -F dir=/var/log/auditd/ -F perm=r -F auid>={{{ uid_min }}} -F auid!=unset -F key=access-audit-trail" >> /etc/audit/audit.rules
