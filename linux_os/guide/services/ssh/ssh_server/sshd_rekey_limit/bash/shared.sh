# platform = multi_platform_all

{{{ bash_instantiate_variables("var_rekey_limit_size", "var_rekey_limit_time") }}}

{{{ bash_sshd_remediation(parameter='RekeyLimit', value="$var_rekey_limit_size $var_rekey_limit_time", config_is_distributed=sshd_distributed_config) -}}}
