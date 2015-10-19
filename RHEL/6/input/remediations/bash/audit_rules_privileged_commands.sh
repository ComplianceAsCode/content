# platform = Red Hat Enterprise Linux 6

# Include source function library.
. /usr/share/scap-security-guide/remediation_functions

# Perform the remediation
perform_audit_rules_privileged_commands_remediation "auditctl" "500"
