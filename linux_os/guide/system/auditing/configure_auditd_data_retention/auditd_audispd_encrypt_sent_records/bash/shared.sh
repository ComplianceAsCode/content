# platform = multi_platform_wrlinux,multi_platform_all
. /usr/share/scap-security-guide/remediation_functions

{{% if product in ["rhel8", "fedora", "ol8", "rhv4"] %}}
AUDISP_REMOTE_CONFIG="/etc/audit/audisp-remote.conf"
option="^transport"
value="KRB5"
{{% else %}}
AUDISP_REMOTE_CONFIG="/etc/audisp/audisp-remote.conf"
option="^enable_krb5"
value="yes"
{{% endif %}}

replace_or_append $AUDISP_REMOTE_CONFIG "$option" "$value" "@CCENUM@"
