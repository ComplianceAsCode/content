#!/bin/bash
# packages = audit
# variables = var_auditd_disk_error_action=halt

source common.sh

echo "disk_error_action = halt" >> /etc/audit/auditd.conf
