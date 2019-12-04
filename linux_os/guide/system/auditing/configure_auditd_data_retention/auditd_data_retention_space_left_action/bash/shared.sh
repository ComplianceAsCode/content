# platform = multi_platform_fedora,multi_platform_ol,multi_platform_rhel,multi_platform_sle
. /usr/share/scap-security-guide/remediation_functions
populate var_auditd_space_left_action

#
# If space_left_action present in /etc/audit/auditd.conf, change value
# to var_auditd_space_left_action, else
# add "space_left_action = $var_auditd_space_left_action" to /etc/audit/auditd.conf
#

AUDITCONFIG=/etc/audit/auditd.conf

replace_or_append $AUDITCONFIG '^space_left_action' "$var_auditd_space_left_action" "@CCENUM@"
