# platform = Red Hat Virtualization 4,multi_platform_fedora,multi_platform_ol,multi_platform_rhel

# Perform the remediation for both possible tools: 'auditctl' and 'augenrules'

{{{ bash_fix_audit_watch_rule("auditctl", "/var/log/tallylog", "wa", "logins") }}}
{{{ bash_fix_audit_watch_rule("augenrules", "/var/log/tallylog", "wa", "logins") }}}

{{{ bash_fix_audit_watch_rule("auditctl", faillock_path, "wa", "logins") }}}
{{{ bash_fix_audit_watch_rule("augenrules", faillock_path, "wa", "logins") }}}

{{{ bash_fix_audit_watch_rule("auditctl", "/var/log/lastlog", "wa", "logins") }}}
{{{ bash_fix_audit_watch_rule("augenrules", "/var/log/lastlog", "wa", "logins") }}}
