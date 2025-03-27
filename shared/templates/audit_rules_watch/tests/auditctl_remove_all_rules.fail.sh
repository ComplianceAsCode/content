#!/bin/bash
# packages = audit

{{{ setup_auditctl_environment() }}}

path={{{ PATH }}}
style={{{ audit_watches_style }}}
. $SHARED/audit_rules_watch/auditctl_remove_all_rules.fail.sh
