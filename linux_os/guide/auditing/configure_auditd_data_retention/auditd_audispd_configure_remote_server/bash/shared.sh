# platform = Red Hat Virtualization 4,multi_platform_fedora,multi_platform_ol,multi_platform_rhel,multi_platform_sle,multi_platform_ubuntu

{{{ bash_instantiate_variables("var_audispd_remote_server") }}}

AUDITCONFIG={{{ audisp_conf_path }}}/audisp-remote.conf

{{% if 'ubuntu' in product %}}
AUREMOTECONFIG={{{ audisp_conf_path }}}/plugins.d/au-remote.conf

{{{ set_config_file("$AUREMOTECONFIG", 'active', 'yes', insensitive="true", separator=" = ", separator_regex="\s*=\s*") }}}
{{% endif %}}

{{{ set_config_file("$AUDITCONFIG", 'remote_server', "$var_audispd_remote_server", insensitive="true", separator=" = ", separator_regex="\s*=\s*") }}}
