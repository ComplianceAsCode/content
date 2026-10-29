#!/bin/bash
# packages = audit

{{{ setup_auditctl_environment() }}}

{{% if REQUIRE_KEY %}}
echo "-a always,exit -F arch=b32 -F {{{ FILTER_TYPE }}}={{{ PATH }}} -F perm=wra -F key={{{ KEY }}}" >> /etc/audit/audit.rules
echo "-a always,exit -F arch=b64 -F {{{ FILTER_TYPE }}}={{{ PATH }}} -F perm=wra -F key={{{ KEY }}}" >> /etc/audit/audit.rules
{{% else %}}
path={{{ PATH }}}
style={{{ audit_watches_style }}}
filter_type={{{ FILTER_TYPE }}}
. $SHARED/audit_rules_watch/auditctl_correct_extra_permission.pass.sh
{{% endif %}}
