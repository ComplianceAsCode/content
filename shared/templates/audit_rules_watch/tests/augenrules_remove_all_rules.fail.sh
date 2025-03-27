#!/bin/bash
# packages = audit

path={{{ PATH }}}
style={{{ audit_watches_style }}}
. $SHARED/audit_rules_watch/augenrules_remove_all_rules.fail.sh
