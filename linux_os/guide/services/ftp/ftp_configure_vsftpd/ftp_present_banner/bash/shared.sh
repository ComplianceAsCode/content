# platform = multi_platform_sle


{{{ bash_replace_or_append('/etc/vsftpd.conf', '^banner_file', '/etc/issue', '%s=%s') }}}
