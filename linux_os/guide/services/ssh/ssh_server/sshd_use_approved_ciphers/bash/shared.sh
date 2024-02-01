# platform = multi_platform_all

{{{ bash_instantiate_variables("sshd_approved_ciphers") }}}

{{{ bash_replace_or_append('/etc/ssh/sshd_config', '^Ciphers', "$sshd_approved_ciphers", '%s %s') }}}
