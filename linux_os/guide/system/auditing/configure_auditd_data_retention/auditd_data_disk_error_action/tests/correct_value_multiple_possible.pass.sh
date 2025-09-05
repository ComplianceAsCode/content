#!/bin/bash
# packages = audit
# variables = var_auditd_disk_error_action=action1|action2|action3

source common.sh

echo "disk_error_action = action1" >> /etc/audit/auditd.conf
echo "disk_error_action = action2" >> /etc/audit/auditd.conf
echo "disk_error_action = action3" >> /etc/audit/auditd.conf
