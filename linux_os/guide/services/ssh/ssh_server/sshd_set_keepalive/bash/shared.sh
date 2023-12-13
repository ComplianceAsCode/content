# platform = multi_platform_rhel,multi_platform_fedora,multi_platform_ol,multi_platform_rhv,multi_platform_sle,multi_platform_ubuntu,multi_platform_debian

{{{ bash_instantiate_variables("var_sshd_set_keepalive") }}}

{{{ bash_sshd_config_set(parameter="ClientAliveCountMax", value="$var_sshd_set_keepalive") }}}
