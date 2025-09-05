# platform = multi_platform_all

# Include source function library.
. /usr/share/scap-security-guide/remediation_functions

{{{ bash_instantiate_variables("var_rekey_limit_size", "var_rekey_limit_time") }}}

{{{ bash_sshd_config_set(parameter='RekeyLimit', value="$var_rekey_limit_size $var_rekey_limit_time") }}}
