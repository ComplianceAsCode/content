#!/bin/bash
# packages = audit

path={{{ PATH }}}
style={{{ audit_watches_style }}}
. $SHARED/audit_rules_login_events/augenrules_wrong_rule_without_key.fail.sh
