#!/bin/bash
# packages = audit

{{{ setup_auditctl_environment() }}}

path={{{ PATH }}}
. $SHARED/audit_rules_login_events/auditctl_remove_all_rules.fail.sh
