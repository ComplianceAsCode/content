# platform = Red Hat Virtualization 4,multi_platform_ol,multi_platform_rhel

{{{ bash_instantiate_variables("var_auditd_disk_error_action") }}}

{{{ bash_replace_or_append("/etc/audit/auditd.conf", '^disk_error_action', "$var_auditd_disk_error_action") }}}
