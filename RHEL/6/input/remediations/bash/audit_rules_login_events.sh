# platform = Red Hat Enterprise Linux 6

# Include source function library.
. /usr/share/scap-security-guide/remediation_functions

# Perform the remediation

fix_audit_watch_rule "auditctl" "/var/log/tallylog" "wa" "logins"
fix_audit_watch_rule "auditctl" "/var/run/faillock/" "wa" "logins"
fix_audit_watch_rule "auditctl" "/var/log/lastlog" "wa" "logins"
