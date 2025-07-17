#!/bin/bash
# packages = audit
{{% if XCCDF_VARIABLE %}}
# variables = {{{ XCCDF_VARIABLE }}}={{{ CORRECT_VALUE }}}
{{% endif %}}
echo "{{{ PARAMETER }}} = {{{ WRONG_VALUE | upper }}}" > "/etc/audit/auditd.conf"
