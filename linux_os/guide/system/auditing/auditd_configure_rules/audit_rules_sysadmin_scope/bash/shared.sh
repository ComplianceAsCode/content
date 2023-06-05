# platform = multi_platform_sle

# Perform the remediation for both possible tools: 'auditctl' and 'augenrules'

{{{ bash_fix_audit_watch_rule("auditctl", "/etc/sudoers", "wa", "scope") }}}
{{{ bash_fix_audit_watch_rule("augenrules", "/etc/sudoers", "wa", "scope") }}}
{{{ bash_fix_audit_watch_rule("auditctl", "/etc/sudoers.d/", "wa", "scope") }}}
{{{ bash_fix_audit_watch_rule("augenrules", "/etc/sudoers.d/", "wa", "scope") }}}

