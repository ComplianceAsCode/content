#!/bin/bash
# platform = multi_platform_ubuntu
# packages = auditd

echo "-w /sbin/fdisk -p x" >> /etc/audit/audit.rules
sed -i "s%^ExecStartPost=.*%ExecStartPost=-/sbin/auditctl%" /usr/lib/systemd/system/auditd.service
