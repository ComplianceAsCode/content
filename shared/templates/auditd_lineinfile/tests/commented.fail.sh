#!/bin/bash
{{% if MISSING_PARAMETER_PASS %}}
# platform = multi_platform_example
{{% endif%}}
# packages = audit
echo "#{{{ PARAMETER }}} = {{{ VALUE }}}" > "/etc/audit/auditd.conf"
