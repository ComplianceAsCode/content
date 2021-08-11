# platform = Red Hat Virtualization 4,multi_platform_fedora,multi_platform_ol,multi_platform_rhel,multi_platform_wrlinux,multi_platform_sle
. /usr/share/scap-security-guide/remediation_functions
{{{ bash_instantiate_variables("var_audispd_remote_server") }}}

{{% if product in ["rhel8", "fedora", "ol8", "rhv4"] %}}
AUDITCONFIG=/etc/audit/audisp-remote.conf
{{% else %}}
AUDITCONFIG=/etc/audisp/audisp-remote.conf
{{% endif %}}

"$AUDITCONFIG", '^remote_server', "$var_audispd_remote_server", "@CCENUM@") }}}
