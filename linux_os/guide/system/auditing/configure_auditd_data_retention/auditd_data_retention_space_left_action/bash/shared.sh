# platform = Red Hat Virtualization 4,multi_platform_fedora,multi_platform_ol,multi_platform_rhel,multi_platform_sle,multi_platform_ubuntu

{{{ bash_instantiate_variables("var_auditd_space_left_action") }}}

var_auditd_space_left_action="$(echo $var_auditd_space_left_action | cut -d \| -f 1)"
#
# If space_left_action present in /etc/audit/auditd.conf, change value
# to var_auditd_space_left_action, else
# add "space_left_action = $var_auditd_space_left_action" to /etc/audit/auditd.conf
#

AUDITCONFIG=/etc/audit/auditd.conf

{{{ bash_replace_or_append("$AUDITCONFIG", '^space_left_action', "$var_auditd_space_left_action") }}}
