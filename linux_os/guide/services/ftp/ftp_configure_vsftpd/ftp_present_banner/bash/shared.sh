# platform = multi_platform_wrlinux,multi_platform_sle


{{{ bash_replace_or_append('/etc/vsftpd.conf', '^banner_file', '/etc/issue', '@CCENUM@', '%s=%s') }}}
