#!/bin/bash
{{% if "ubuntu" in product%}}
# packages = auditd
{{% else %}}
# packages = audit
{{% endif %}}
# variables = var_auditd_disk_full_action=action1

source common.sh

echo "disk_full_action = action1" >> /etc/audit/auditd.conf
echo "disk_full_action = non_valid_action" >> /etc/audit/auditd.conf
