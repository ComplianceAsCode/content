#!/bin/bash
# packages = audit
{{% if XCCDF_VARIABLE %}}
# platform = Not Applicable
{{% endif %}}
echo "{{{ PARAMETER | upper }}} = {{{ VALUE | upper }}}" > "/etc/audit/auditd.conf"
