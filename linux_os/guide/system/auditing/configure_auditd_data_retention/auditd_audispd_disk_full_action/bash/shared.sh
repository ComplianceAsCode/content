# platform = multi_platform_sle

. /usr/share/scap-security-guide/remediation_functions

package_install audit-audispd-plugins || exit 1

{{% if product in ["rhel8", "fedora", "ol8"] %}}
AUDITCONFIG=/etc/audit/audisp-remote.conf
{{% else %}}
AUDITCONFIG=/etc/audisp/audisp-remote.conf
{{% endif %}}

replace_or_append $AUDITCONFIG '^disk_full_action' "single" "@CCENUM@"
