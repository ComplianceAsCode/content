# platform = multi_platform_all
# reboot = false
# strategy = configure
# complexity = low
# disruption = low

{{{ bash_instantiate_variables("var_sshd_set_login_grace_time") }}}

{{{ bash_sshd_config_set(parameter="LoginGraceTime", value="$var_sshd_set_login_grace_time") }}}
