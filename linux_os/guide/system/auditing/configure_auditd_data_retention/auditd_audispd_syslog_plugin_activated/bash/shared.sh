# platform = multi_platform_all
var_syslog_active="yes"

AUDISP_SYSLOGCONFIG={{{ audisp_conf_path }}}/plugins.d/syslog.conf

{{{ bash_replace_or_append("$AUDISP_SYSLOGCONFIG", '^active', "$var_syslog_active") }}}
