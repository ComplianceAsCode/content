# platform = Red Hat Enterprise Linux 6

# Include source function library.
INCLUDE_SHARED_REMEDIATION_FUNCTIONS

# Perform the remediation
fix_audit_watch_rule "auditctl" "/etc/selinux/" "wa" "MAC-policy"
