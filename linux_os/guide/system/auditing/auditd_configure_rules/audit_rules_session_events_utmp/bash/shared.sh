# platform = multi_platform_sle,multi_platform_ubuntu

# Perform the remediation for both possible tools: 'auditctl' and 'augenrules'
{{{ bash_fix_audit_watch_rule("auditctl", "/run/utmp", "wa", "session") }}}
{{{ bash_fix_audit_watch_rule("augenrules", "/run/utmp", "wa", "session") }}}
