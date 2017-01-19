# platform = Red Hat Enterprise Linux 6

# Include source function library.
. $SHARED_REMEDIATION_FUNCTIONS

# Perform the remediation
perform_audit_rules_privileged_commands_remediation "auditctl" "500"
