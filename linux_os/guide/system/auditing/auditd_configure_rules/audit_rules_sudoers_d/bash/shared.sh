# platform = multi_platform_all

# Include source function library.
. /usr/share/scap-security-guide/remediation_functions

# Perform the remediation for both possible tools: 'auditctl' and 'augenrules'
fix_audit_watch_rule "auditctl" "/etc/sudoers.d/" "wa" "actions"
fix_audit_watch_rule "augenrules" "/etc/sudoers.d/" "wa" "actions"
