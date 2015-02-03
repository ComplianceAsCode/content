
# Include source function library.
. /usr/share/scap-security-guide/functions
# Perform the remediation
fix_audit_watch_rule "/etc/group" "wa" "audit_rules_usergroup_modification"
fix_audit_watch_rule "/etc/passwd" "wa" "audit_rules_usergroup_modification"
fix_audit_watch_rule "/etc/gshadow" "wa" "audit_rules_usergroup_modification"
fix_audit_watch_rule "/etc/shadow" "wa" "audit_rules_usergroup_modification"
fix_audit_watch_rule "/etc/security/opasswd" "wa" "audit_rules_usergroup_modification"
