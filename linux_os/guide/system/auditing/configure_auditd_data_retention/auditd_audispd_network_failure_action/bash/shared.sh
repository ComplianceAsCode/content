# platform = multi_platform_sle
. /usr/share/scap-security-guide/remediation_functions

{{% if product == "sle12" %}}
package_install audit-audispd-plugins || exit 1
{{% endif %}}


replace_or_append '/etc/audisp/audisp-remote.conf' '^network_failure_action' syslog
