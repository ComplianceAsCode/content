# platform = multi_platform_all
. /usr/share/scap-security-guide/remediation_functions
var_syslog_active="yes"

AUDISP_SYSLOGCONFIG=/etc/audisp/plugins.d/syslog.conf

replace_or_append $AUDISP_SYSLOGCONFIG '^active' "$var_syslog_active" "@CCENUM@"
