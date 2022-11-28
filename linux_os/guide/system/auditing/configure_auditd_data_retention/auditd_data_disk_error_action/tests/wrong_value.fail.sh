#!/bin/bash
# packages = audit

source common.sh

echo "disk_error_action = non_valid_action" >> /etc/audit/auditd.conf
