# platform = multi_platform_rhel,multi_platform_ol,multi_platform_fedora,multi_platform_ol,multi_platform_sle
. /usr/share/scap-security-guide/remediation_functions
populate var_audispd_remote_server

if [[ "$var_audispd_remote_server" = "myhost.mydomain.com" ]] ; then
    echo "Refusing to set the audispd remote server to the unusable default value. Please configure the 'var_audispd_remote_server' variable before continuing." >&2
    exit 1
fi

{{% if product in ["rhel8", "fedora", "ol8"] %}}
AUDITCONFIG=/etc/audit/audisp-remote.conf
{{% else %}}
AUDITCONFIG=/etc/audisp/audisp-remote.conf
{{% endif %}}

replace_or_append $AUDITCONFIG '^remote_server' "$var_audispd_remote_server" "@CCENUM@"
