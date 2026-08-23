# platform = multi_platform_ubuntu

# Perform the remediation for both possible tools: 'auditctl' and 'augenrules'
{{{ bash_fix_audit_watch_rule("auditctl", "/etc/apparmor/", "wa", "MAC-policy") }}}
{{{ bash_fix_audit_watch_rule("augenrules", "/etc/apparmor/", "wa", "MAC-policy") }}}
{{{ bash_fix_audit_watch_rule("auditctl", "/etc/apparmor.d/", "wa", "MAC-policy") }}}
{{{ bash_fix_audit_watch_rule("augenrules", "/etc/apparmor.d/", "wa", "MAC-policy") }}}
