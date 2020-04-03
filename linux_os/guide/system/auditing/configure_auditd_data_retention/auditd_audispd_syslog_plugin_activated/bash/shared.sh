# platform = multi_platform_all
. /usr/share/scap-security-guide/remediation_functions
var_syslog_active="yes"

{{% if product in ["rhel8", "fedora", "ol8", "rhv4"] %}}
AUDISP_SYSLOGCONFIG=/etc/audit/plugins.d/syslog.conf
{{% else %}}
AUDISP_SYSLOGCONFIG=/etc/audisp/plugins.d/syslog.conf
{{% endif %}}

replace_or_append $AUDISP_SYSLOGCONFIG '^active' "$var_syslog_active" "@CCENUM@"
