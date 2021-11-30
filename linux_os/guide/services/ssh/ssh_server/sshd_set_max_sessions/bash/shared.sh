# platform = multi_platform_all
# reboot = false
# strategy = configure
# complexity = low
# disruption = low

{{{ bash_instantiate_variables("var_sshd_max_sessions") }}}

{{{ bash_sshd_config_set(parameter="MaxSessions", value="$var_sshd_max_sessions") }}}
