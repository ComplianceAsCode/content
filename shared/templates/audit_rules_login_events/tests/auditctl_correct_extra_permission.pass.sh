#!/bin/bash
# packages = audit

{{{ setup_auditctl_environment() }}}

path={{{ PATH }}}
. $SHARED/audit_rules_login_events/auditctl_correct_extra_permission.pass.sh
