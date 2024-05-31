# platform = Red Hat Virtualization 4,multi_platform_ol,multi_platform_rhel,multi_platform_sle

# Perform the remediation for both possible tools: 'auditctl' and 'augenrules'
{{{ bash_fix_audit_watch_rule("auditctl", "/etc/group", "wa", "audit_rules_usergroup_modification") }}}
{{{ bash_fix_audit_watch_rule("augenrules", "/etc/group", "wa", "audit_rules_usergroup_modification") }}}
{{{ bash_fix_audit_watch_rule("auditctl", "/etc/passwd", "wa", "audit_rules_usergroup_modification") }}}
{{{ bash_fix_audit_watch_rule("augenrules", "/etc/passwd", "wa", "audit_rules_usergroup_modification") }}}
{{{ bash_fix_audit_watch_rule("auditctl", "/etc/gshadow", "wa", "audit_rules_usergroup_modification") }}}
{{{ bash_fix_audit_watch_rule("augenrules", "/etc/gshadow", "wa", "audit_rules_usergroup_modification") }}}
{{{ bash_fix_audit_watch_rule("auditctl", "/etc/shadow", "wa", "audit_rules_usergroup_modification") }}}
{{{ bash_fix_audit_watch_rule("augenrules", "/etc/shadow", "wa", "audit_rules_usergroup_modification") }}}
{{{ bash_fix_audit_watch_rule("auditctl", "/etc/security/opasswd", "wa", "audit_rules_usergroup_modification") }}}
{{{ bash_fix_audit_watch_rule("augenrules", "/etc/security/opasswd", "wa", "audit_rules_usergroup_modification") }}}
