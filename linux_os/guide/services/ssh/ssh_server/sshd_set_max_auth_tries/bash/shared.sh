# platform = multi_platform_rhel,multi_platform_fedora,multi_platform_ol,multi_platform_rhv,multi_platform_sle

{{{ bash_instantiate_variables("sshd_max_auth_tries_value") }}}

{{{ bash_sshd_config_set(parameter="MaxAuthTries", value="$sshd_max_auth_tries_value") }}}
