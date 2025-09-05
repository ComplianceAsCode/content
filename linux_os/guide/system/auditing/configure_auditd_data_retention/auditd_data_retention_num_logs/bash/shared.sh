# platform = multi_platform_all
. /usr/share/scap-security-guide/remediation_functions
{{{ bash_instantiate_variables("var_auditd_num_logs") }}}

AUDITCONFIG=/etc/audit/auditd.conf

replace_or_append $AUDITCONFIG '^num_logs' "$var_auditd_num_logs" "@CCENUM@"
