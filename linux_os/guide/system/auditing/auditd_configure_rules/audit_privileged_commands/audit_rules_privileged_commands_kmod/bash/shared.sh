# platform = multi_platform_sle,multi_platform_ubuntu

# Perform the remediation for both possible tools: 'auditctl' and 'augenrules'
{{{ bash_fix_audit_watch_rule("auditctl", "/usr/bin/kmod", "x", "modules") }}}
{{{ bash_fix_audit_watch_rule("augenrules", "/usr/bin/kmod", "x", "modules") }}}
