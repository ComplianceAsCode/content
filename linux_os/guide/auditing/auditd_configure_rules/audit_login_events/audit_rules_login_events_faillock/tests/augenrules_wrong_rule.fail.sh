#!/bin/bash
# packages = audit
# platform = multi_platform_all
# variables = var_accounts_passwords_pam_faillock_dir=/var/log/faillock

path="/var/log/faillock"
style="{{{ audit_watches_style }}}"
. $SHARED/audit_rules_login_events/augenrules_wrong_rule.fail.sh
