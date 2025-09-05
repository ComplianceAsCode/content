#!/bin/bash
{{% if "ubuntu" in product%}}
# packages = auditd
{{% else %}}
# packages = audit
{{% endif %}}

source common.sh

echo "disk_full_action = non_valid_action" >> /etc/audit/auditd.conf
