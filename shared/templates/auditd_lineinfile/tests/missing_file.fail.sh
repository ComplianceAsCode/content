#!/bin/bash
{{% if MISSING_PARAMETER_PASS %}}
# platform = multi_platform_example
{{% endif%}}
# packages = audit
rm -f "/etc/audit/auditd.conf"
