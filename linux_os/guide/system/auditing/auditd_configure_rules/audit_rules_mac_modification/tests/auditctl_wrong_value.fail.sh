#!/bin/bash

# use auditctl
sed -i "s%^ExecStartPost=.*%ExecStartPost=-/sbin/auditctl%" /usr/lib/systemd/system/auditd.service

echo "-w /etc/passwd -p w -k MAC-policy" > /etc/audit/audit.rules

