
# Include source function library.
. /usr/share/scap-security-guide/functions
# Perform the remediation
fix_audit_watch_rule "/etc/selinux/" "wa" "MAC-policy"
