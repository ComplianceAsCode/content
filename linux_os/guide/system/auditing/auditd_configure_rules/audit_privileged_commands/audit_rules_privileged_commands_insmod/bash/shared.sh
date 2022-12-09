# platform = multi_platform_rhel,multi_platform_sle,multi_platform_ubuntu

# Perform the remediation for both possible tools: 'auditctl' and 'augenrules'
{{{ bash_fix_audit_watch_rule("auditctl", "/sbin/insmod", "x", "modules") }}}
{{{ bash_fix_audit_watch_rule("augenrules", "/sbin/insmod", "x", "modules") }}}
