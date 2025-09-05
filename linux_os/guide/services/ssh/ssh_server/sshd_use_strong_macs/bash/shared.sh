# platform = multi_platform_all

{{{ bash_instantiate_variables("sshd_strong_macs") }}}

{{{ bash_replace_or_append('/etc/ssh/sshd_config', '^MACs', "$sshd_strong_macs", '%s %s') }}}

