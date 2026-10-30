#!/bin/bash
# packages = audit

{{{ setup_augenrules_environment() }}}

{{% if REQUIRE_KEY %}}
echo "-a always,exit -F arch=b32 -F {{{ FILTER_TYPE }}}={{{ PATH }}} -F perm=wa -F key={{{ KEY }}}" >> /etc/audit/rules.d/test.rules
echo "-a always,exit -F arch=b64 -F {{{ FILTER_TYPE }}}={{{ PATH }}} -F perm=wa -F key={{{ KEY }}}" >> /etc/audit/rules.d/test.rules
{{% else %}}
path={{{ PATH }}}
style={{{ audit_watches_style }}}
filter_type={{{ FILTER_TYPE }}}
. $SHARED/audit_rules_watch/augenrules_correct_without_key.pass.sh
{{% endif %}}
