# platform = multi_platform_rhel, multi_platform_fedora

{{{ bash_replace_or_append('/etc/ssh/sshd_config', '^MACs', "wrong_value_expected_to_fail.com", '@CCENUM@', '%s %s') }}}
