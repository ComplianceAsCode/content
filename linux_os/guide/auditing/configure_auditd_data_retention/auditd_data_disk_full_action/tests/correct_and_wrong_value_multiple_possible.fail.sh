#!/bin/bash
# packages = audit
# variables = var_auditd_disk_full_action=action1|action2|action3

source common.sh

echo "disk_full_action = action1" >> /etc/audit/auditd.conf
echo "disk_full_action = action2" >> /etc/audit/auditd.conf
echo "disk_full_action = action3" >> /etc/audit/auditd.conf
echo "disk_full_action = non_valid_action" >> /etc/audit/auditd.conf
