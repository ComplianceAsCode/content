# platform = multi_platform_wrlinux,multi_platform_rhel,multi_platform_fedora,multi_platform_ol,multi_platform_rhv

# Include source function library.
. /usr/share/scap-security-guide/remediation_functions

# Perform the remediation for both possible tools: 'auditctl' and 'augenrules'
perform_audit_rules_privileged_commands_remediation "auditctl" "{{{ auid }}}"
perform_audit_rules_privileged_commands_remediation "augenrules" "{{{ auid }}}"
