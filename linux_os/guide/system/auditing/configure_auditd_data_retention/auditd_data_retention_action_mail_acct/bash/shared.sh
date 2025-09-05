# platform = Red Hat Virtualization 4,multi_platform_fedora,multi_platform_ol,multi_platform_rhel,multi_platform_wrlinux,multi_platform_sle
. /usr/share/scap-security-guide/remediation_functions
{{{ bash_instantiate_variables("var_auditd_action_mail_acct") }}}

AUDITCONFIG=/etc/audit/auditd.conf

replace_or_append $AUDITCONFIG '^action_mail_acct' "$var_auditd_action_mail_acct" "@CCENUM@"
