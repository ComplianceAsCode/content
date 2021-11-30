# platform = multi_platform_all

{{{ bash_instantiate_variables("var_rekey_limit_size", "var_rekey_limit_time") }}}

{{{ bash_sshd_config_set(parameter='RekeyLimit', value="$var_rekey_limit_size $var_rekey_limit_time") }}}
