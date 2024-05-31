#!/bin/bash
# packages = audit
# platform = multi_platform_all

path="/var/log/faillock"
. $SHARED/audit_rules_login_events/augenrules_wrong_rule_without_key.fail.sh
