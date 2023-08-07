# platform = multi_platform_ubuntu

# Perform the remediation for both possible tools: 'auditctl' and 'augenrules'
{{{ bash_fix_audit_watch_rule("auditctl", "/bin/kmod", "x", "modules") }}}
{{{ bash_fix_audit_watch_rule("augenrules", "/bin/kmod", "x", "modules") }}}
