#!/bin/bash
# packages = audit
# platform = multi_platform_rhel
# variables = var_accounts_passwords_pam_faillock_dir=/var/run/faillock

{{{ setup_auditctl_environment() }}}

path="/var/run/faillock"
style="{{{ audit_watches_style }}}"
. $SHARED/audit_rules_login_events/auditctl_remove_all_rules.fail.sh
