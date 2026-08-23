#!/bin/bash
# packages = audit
{{% if XCCDF_VARIABLE %}}
# variables = {{{ XCCDF_VARIABLE }}}={{{ TEST_CORRECT_VALUE }}}
{{% endif %}}
echo "{{{ PARAMETER }}} = {{{ TEST_CORRECT_VALUE }}}" >> "/etc/audit/auditd.conf"
echo "{{{ PARAMETER }}} = {{{ TEST_WRONG_VALUE }}}" >> "/etc/audit/auditd.conf"
