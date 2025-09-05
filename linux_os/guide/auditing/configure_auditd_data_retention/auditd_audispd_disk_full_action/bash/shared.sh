# platform = Red Hat Virtualization 4,multi_platform_fedora,multi_platform_ol,multi_platform_rhel,multi_platform_sle,multi_platform_ubuntu

{{{ bash_instantiate_variables("var_audispd_disk_full_action") }}}

AUDITCONFIG={{{ audisp_conf_path }}}/audisp-remote.conf

{{{ bash_replace_or_append("$AUDITCONFIG", '^disk_full_action', "$var_audispd_disk_full_action") }}}
