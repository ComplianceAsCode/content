# platform = Red Hat Virtualization 4,multi_platform_fedora,multi_platform_ol,multi_platform_rhel,multi_platform_wrlinux,multi_platform_sle

{{{ bash_instantiate_variables("var_auditd_admin_space_left_action") }}}

AUDITCONFIG=/etc/audit/auditd.conf

{{{ bash_replace_or_append("$AUDITCONFIG", '^admin_space_left_action', "$var_auditd_admin_space_left_action") }}}
