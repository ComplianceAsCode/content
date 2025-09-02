#!/bin/bash
# packages = audit
{{% if XCCDF_VARIABLE %}}
# platform = Not Applicable
{{% endif %}}
echo "{{{ PARAMETER | upper }}} = {{{ WRONG_VALUE | upper }}}" > "/etc/audit/auditd.conf"
