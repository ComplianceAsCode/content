#!/bin/bash
# packages = audit

{{{ setup_augenrules_environment() }}}

path={{{ PATH }}}
style={{{ audit_watches_style }}}
filter_type={{{ FILTER_TYPE }}}
. $SHARED/audit_rules_watch/augenrules_wrong_rule.fail.sh
