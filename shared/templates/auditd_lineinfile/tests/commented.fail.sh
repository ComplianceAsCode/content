#!/bin/bash
{{% if MISSING_PARAMETER_PASS %}}
# platform = Not Applicable
{{% endif%}}
# packages = audit
{{% if XCCDF_VARIABLE %}}
# variables = {{{ XCCDF_VARIABLE }}}={{{ CORRECT_VALUE }}}
{{% endif %}}
echo "#{{{ PARAMETER }}} = {{{ CORRECT_VALUE }}}" > "/etc/audit/auditd.conf"
