# platform = multi_platform_all
# reboot = false
# strategy = restrict
# complexity = low
# disruption = low

{{{ bash_instantiate_variables("var_sshd_priv_separation") }}}

{{{ bash_sshd_config_set(parameter="UsePrivilegeSeparation", value="$var_sshd_priv_separation") }}}
