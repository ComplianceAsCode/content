# platform = multi_platform_all

# Perform the remediation for both possible tools: 'auditctl' and 'augenrules'
{{{ bash_fix_audit_watch_rule("auditctl", "/etc/sudoers", "wa", "actions") }}}
{{{ bash_fix_audit_watch_rule("augenrules", "/etc/sudoers", "wa", "actions") }}}
