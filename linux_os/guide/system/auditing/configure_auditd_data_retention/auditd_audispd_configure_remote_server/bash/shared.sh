# platform = Red Hat Virtualization 4,multi_platform_fedora,multi_platform_ol,multi_platform_rhel,multi_platform_wrlinux,multi_platform_sle,multi_platform_ubuntu

{{{ bash_instantiate_variables("var_audispd_remote_server") }}}

{{% if product in ["rhel8", "fedora", "ol8", "rhv4"] %}}
AUDITCONFIG=/etc/audit/audisp-remote.conf
{{% else %}}
AUDITCONFIG=/etc/audisp/audisp-remote.conf
AUREMOTECONFIG=/etc/audisp/plugins.d/au-remote.conf
{{% endif %}}

{{% if 'ubuntu' in product %}}
{{{ bash_replace_or_append("$AUREMOTECONFIG", '^active', 'yes') }}}
{{% endif %}}

{{{ bash_replace_or_append("$AUDITCONFIG", '^remote_server', "$var_audispd_remote_server") }}}
