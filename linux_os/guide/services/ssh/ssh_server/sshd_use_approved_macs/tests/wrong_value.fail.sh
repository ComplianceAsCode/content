# platform = multi_platform_rhel, multi_platform_fedora

{{{ bash_instantiate_variables("wrong_value_expected_to_fail.com") }}}

{{{ bash_replace_or_append('/etc/ssh/sshd_config', '^MACs', "$sshd_approved_macs", '@CCENUM@', '%s %s') }}}
