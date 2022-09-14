#!/bin/bash
# platform = multi_platform_ubuntu
# packages = auditd

echo "-w /sbin/fdisk -p x" >> /etc/audit/rules.d/modules.rules
