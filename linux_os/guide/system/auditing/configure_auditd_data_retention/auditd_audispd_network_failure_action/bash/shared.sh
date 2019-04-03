# platform = multi_platform_sle
. /usr/share/scap-security-guide/remediation_functions

package_install audit-audispd-plugins || exit 1

replace_or_append '/etc/audisp/audisp-remote.conf' '^network_failure_action' syslog
