# platform = Red Hat Virtualization 4,multi_platform_ol,multi_platform_rhel,multi_platform_sle,multi_platform_ubuntu

{{{ bash_instantiate_variables("var_auditd_disk_full_action") }}}

{{{ bash_replace_or_append("/etc/audit/auditd.conf", '^disk_full_action', "$var_auditd_disk_full_action") }}}
