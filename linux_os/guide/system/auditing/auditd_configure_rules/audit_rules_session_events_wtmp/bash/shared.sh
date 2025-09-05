# platform = multi_platform_sle,multi_platform_ubuntu

# Perform the remediation for both possible tools: 'auditctl' and 'augenrules'
{{{ bash_fix_audit_watch_rule("auditctl", "/var/log/wtmp", "wa", "session") }}}
{{{ bash_fix_audit_watch_rule("augenrules", "/var/log/wtmp", "wa", "session") }}}
