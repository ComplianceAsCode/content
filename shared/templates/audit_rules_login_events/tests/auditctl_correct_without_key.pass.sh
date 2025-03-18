#!/bin/bash
# packages = audit

{{{ setup_auditctl_environment() }}}

path={{{ PATH }}}
style={{{ audit_watches_style }}}
. $SHARED/audit_rules_login_events/auditctl_correct_without_key.pass.sh
