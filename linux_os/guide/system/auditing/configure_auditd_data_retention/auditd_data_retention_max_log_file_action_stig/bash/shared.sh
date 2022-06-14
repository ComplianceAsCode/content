# platform = Red Hat Virtualization 4,multi_platform_fedora,multi_platform_ol,multi_platform_rhel,multi_platform_sle

{{{ bash_instantiate_variables("var_auditd_max_log_file_action") }}}

{{{ bash_replace_or_append("/etc/audit/auditd.conf", '^max_log_file_action', "$var_auditd_max_log_file_action") }}}
