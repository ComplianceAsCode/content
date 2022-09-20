#!/bin/bash
{{% if MISSING_PARAMETER_PASS %}}
# platform = Not Applicable
{{% endif%}}
# packages = audit
rm -f "/etc/audit/auditd.conf"
