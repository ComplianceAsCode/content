#!/bin/bash
# packages = audit
# variables = var_auditd_disk_full_action=halt

source common.sh

echo "disk_full_action = halt" >> /etc/audit/auditd.conf
