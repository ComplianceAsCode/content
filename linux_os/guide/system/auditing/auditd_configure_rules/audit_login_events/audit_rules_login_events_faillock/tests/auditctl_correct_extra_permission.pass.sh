#!/bin/bash
# packages = audit
# platform = multi_platform_all

path="/var/log/faillock"
. $SHARED/audit_rules_login_events/auditctl_correct_extra_permission.pass.sh
