# platform = Red Hat Enterprise Linux 6

# Include source function library.
INCLUDE_SHARED_REMEDIATION_FUNCTIONS

# Perform the remediation
fix_audit_watch_rule "auditctl" "/var/run/utmp" "wa" "session"
fix_audit_watch_rule "auditctl" "/var/log/btmp" "wa" "session"
fix_audit_watch_rule "auditctl" "/var/log/wtmp" "wa" "session"
