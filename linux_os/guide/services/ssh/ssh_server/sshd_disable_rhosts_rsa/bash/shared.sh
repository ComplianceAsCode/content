# platform = multi_platform_rhel,multi_platform_fedora,multi_platform_ol,multi_platform_rhv


{{{ bash_replace_or_append('/etc/ssh/sshd_config', '^RhostsRSAAuthentication', 'no', '%s %s') }}}
