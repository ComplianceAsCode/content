# platform = multi_platform_all

{{{ bash_instantiate_variables("var_auditd_num_logs") }}}

AUDITCONFIG=/etc/audit/auditd.conf

{{{ bash_replace_or_append("$AUDITCONFIG", '^num_logs', "$var_auditd_num_logs") }}}
