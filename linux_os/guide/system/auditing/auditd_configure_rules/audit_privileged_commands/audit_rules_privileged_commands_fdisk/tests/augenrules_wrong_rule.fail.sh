#!/bin/bash
# platform = multi_platform_ubuntu
# packages = auditd

echo "-w /sbin/something -p x -k modules" >> /etc/audit/rules.d/modules.rules
