#!/bin/bash
# packages = audit

{{{ setup_auditctl_environment() }}}
path={{{ PATH }}}
style={{{ audit_watches_style }}}
filter_type={{{ FILTER_TYPE }}}
. $SHARED/audit_rules_watch/auditctl_alternate_filter_type.pass.sh
