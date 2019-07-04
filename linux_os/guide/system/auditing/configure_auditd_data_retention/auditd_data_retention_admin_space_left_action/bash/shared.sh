# platform = multi_platform_wrlinux,multi_platform_rhel,multi_platform_ol,multi_platform_fedora
. /usr/share/scap-security-guide/remediation_functions

populate var_auditd_admin_space_left_action

AUDITCONFIG=/etc/audit/auditd.conf

replace_or_append $AUDITCONFIG '^admin_space_left_action' "$var_auditd_admin_space_left_action" "@CCENUM@"
