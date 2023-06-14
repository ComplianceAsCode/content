# platform = multi_platform_sle

{{{ bash_instantiate_variables("rsyslog_remote_loghost_address") }}}
{{{ bash_comment_config_line("/etc/rsyslog.conf", '^\*\.\*') }}}
{{{ bash_comment_config_line("/etc/rsyslog.d/*.conf", '^\*\.\*') }}}
{{{ bash_replace_or_append('/etc/rsyslog.d/remote.conf', '^\*\.\*', "@@$rsyslog_remote_loghost_address", '%s %s') }}}
