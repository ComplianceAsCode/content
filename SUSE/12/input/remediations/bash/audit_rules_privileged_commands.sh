# platform = Red Hat Enterprise Linux 7

# Include source function library.
. /usr/share/scap-security-guide/remediation_functions

# Perform the remediation for both possible tools: 'auditctl' and 'augenrules'
perform_audit_rules_privileged_commands_remediation "auditctl" "1000"
perform_audit_rules_privileged_commands_remediation "augenrules" "1000"
