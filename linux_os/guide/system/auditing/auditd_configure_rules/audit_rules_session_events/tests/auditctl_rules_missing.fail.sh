#!/bin/bash

# use auditctl
sed -i "s%^ExecStartPost=.*%ExecStartPost=-/sbin/auditctl%" /usr/lib/systemd/system/auditd.service

rm -rf /etc/audit/rules.d/*
rm /etc/audit/audit.rules
