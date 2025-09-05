# platform = Red Hat Virtualization 4,multi_platform_fedora,multi_platform_ol,multi_platform_rhel,multi_platform_sle

{{{ bash_instantiate_variables("var_auditd_action_mail_acct") }}}

AUDITCONFIG=/etc/audit/auditd.conf

{{{ bash_replace_or_append("$AUDITCONFIG", '^action_mail_acct', "$var_auditd_action_mail_acct") }}}
