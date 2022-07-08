# platform = multi_platform_rhel,multi_platform_ol,multi_platform_rhv,multi_platform_sle

{{{ bash_instantiate_variables("var_sshd_disable_compression") }}}

{{{ bash_replace_or_append('/etc/ssh/sshd_config', '^Compression', "$var_sshd_disable_compression", '%s %s') }}}
