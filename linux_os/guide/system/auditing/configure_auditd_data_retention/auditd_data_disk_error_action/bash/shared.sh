# platform = Red Hat Virtualization 4,multi_platform_ol,multi_platform_rhel

{{{ bash_instantiate_variables("var_auditd_disk_error_action") }}}

#
# If disk_error_action present in /etc/audit/auditd.conf, change value
# to var_auditd_disk_error_action, else
# add "disk_error_action = $var_auditd_disk_error_action" to /etc/audit/auditd.conf
#
var_auditd_disk_error_action="$(echo $var_auditd_disk_error_action | cut -d \| -f 1)"

{{{ bash_replace_or_append("/etc/audit/auditd.conf", '^disk_error_action', "$var_auditd_disk_error_action") }}}
