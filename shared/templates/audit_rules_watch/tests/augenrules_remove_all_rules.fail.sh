#!/bin/bash
# packages = audit

path={{{ PATH }}}
style={{{ audit_watches_style }}}
filter_type={{{ FILTER_TYPE }}}
. $SHARED/audit_rules_watch/augenrules_remove_all_rules.fail.sh
