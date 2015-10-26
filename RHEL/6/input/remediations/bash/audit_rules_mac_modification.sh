# platform = Red Hat Enterprise Linux 6

# Include source function library.
. /usr/share/scap-security-guide/remediation_functions

# Perform the remediation
fix_audit_watch_rule "auditctl" "/etc/selinux/" "wa" "MAC-policy"
