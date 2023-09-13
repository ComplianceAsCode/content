# platform = Red Hat Virtualization 4,multi_platform_fedora,multi_platform_ol,multi_platform_rhel

# Perform the remediation for both possible tools: 'auditctl' and 'augenrules'

{{{ bash_instantiate_variables("var_accounts_passwords_pam_faillock_dir") }}}

{{{ bash_fix_audit_watch_rule("auditctl", "/var/log/tallylog", "wa", "logins") }}}
{{{ bash_fix_audit_watch_rule("augenrules", "/var/log/tallylog", "wa", "logins") }}}

{{{ bash_fix_audit_watch_rule("auditctl", "${var_accounts_passwords_pam_faillock_dir}", "wa", "logins") }}}
{{{ bash_fix_audit_watch_rule("augenrules", "${var_accounts_passwords_pam_faillock_dir}", "wa", "logins") }}}

{{{ bash_fix_audit_watch_rule("auditctl", "/var/log/lastlog", "wa", "logins") }}}
{{{ bash_fix_audit_watch_rule("augenrules", "/var/log/lastlog", "wa", "logins") }}}
