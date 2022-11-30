#!/bin/bash
# packages = audit

source common.sh

echo "disk_full_action = non_valid_action" >> /etc/audit/auditd.conf
