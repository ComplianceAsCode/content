# platform = Red Hat Virtualization 4,multi_platform_fedora,multi_platform_ol,multi_platform_rhel,multi_platform_sle,multi_platform_ubuntu

{{{ bash_instantiate_variables("var_audispd_remote_server") }}}

AUDITCONFIG={{{ audisp_conf_path }}}/audisp-remote.conf

{{% if 'ubuntu' in product %}}
AUREMOTECONFIG=/etc/audisp/plugins.d/au-remote.conf

{{{ bash_replace_or_append("$AUREMOTECONFIG", '^active', 'yes') }}}
{{% endif %}}

{{{ bash_replace_or_append("$AUDITCONFIG", '^remote_server', "$var_audispd_remote_server") }}}
