# platform = multi_platform_rhel,multi_platform_ol
. /usr/share/scap-security-guide/remediation_functions
populate var_auditd_action_mail_acct

AUDITCONFIG=/etc/audit/auditd.conf

replace_or_append $AUDITCONFIG '^action_mail_acct' "$var_auditd_action_mail_acct" "@CCENUM@"
