#!/bin/bash
{{% if MISSING_PARAMETER_PASS %}}
# platform = multi_platform_example
{{% endif%}}
# packages = audit
touch "/etc/audit/auditd.conf"
sed -i "/{{{ PARAMETER }}}/d" "/etc/audit/auditd.conf"
