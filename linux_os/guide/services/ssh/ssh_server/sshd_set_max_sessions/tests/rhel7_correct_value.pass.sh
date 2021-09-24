# platform = Red Hat Enterprise Linux 7

{{{ bash_instantiate_variables("var_sshd_max_sessions") }}}

{{{ bash_sshd_config_set(parameter="MaxSessions", value="$var_sshd_max_sessions") }}}
