#!/bin/bash
# packages = audit
# platform = multi_platform_all

{{{ setup_auditctl_environment() }}}

. $SHARED/audit_rules_watch/auditctl_remove_all_rules.fail.sh
