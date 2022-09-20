#!/bin/bash
{{% if MISSING_PARAMETER_PASS %}}
# platform = Not Applicable
{{% endif%}}
# packages = audit
touch "/etc/audit/auditd.conf"
sed -i "/{{{ PARAMETER }}}/d" "/etc/audit/auditd.conf"
