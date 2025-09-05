#!/bin/bash
{{% if MISSING_PARAMETER_PASS %}}
# platform = Not Applicable
{{% endif%}}
# packages = audit
echo "#{{{ PARAMETER }}} = {{{ VALUE }}}" > "/etc/audit/auditd.conf"
