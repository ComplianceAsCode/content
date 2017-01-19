# platform = Red Hat Enterprise Linux 6

# Include source function library.
. $SHARED_REMEDIATION_FUNCTIONS

# Perform the remediation
fix_audit_watch_rule "auditctl" "/etc/group" "wa" "audit_rules_usergroup_modification"
fix_audit_watch_rule "auditctl" "/etc/passwd" "wa" "audit_rules_usergroup_modification"
fix_audit_watch_rule "auditctl" "/etc/gshadow" "wa" "audit_rules_usergroup_modification"
fix_audit_watch_rule "auditctl" "/etc/shadow" "wa" "audit_rules_usergroup_modification"
fix_audit_watch_rule "auditctl" "/etc/security/opasswd" "wa" "audit_rules_usergroup_modification"
