# platform = multi_platform_wrlinux,Red Hat Enterprise Linux 7,Oracle Linux 7


{{{ bash_instantiate_variables("sshd_approved_ciphers") }}}

{{{ bash_replace_or_append('/etc/ssh/sshd_config', '^Ciphers', "$sshd_approved_ciphers", '@CCENUM@', '%s %s') }}}
