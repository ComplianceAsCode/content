# platform = multi_platform_rhel,multi_platform_fedora,multi_platform_ol,multi_platform_rhv,multi_platform_sle

# Perform the remediation for both possible tools: 'auditctl' and 'augenrules'
{{{ bash_perform_audit_rules_privileged_commands_remediation("auditctl", auid) }}}
{{{ bash_perform_audit_rules_privileged_commands_remediation("augenrules", auid) }}}
