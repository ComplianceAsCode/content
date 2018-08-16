# platform = multi_platform_rhel

# Include source function library.
. /usr/share/scap-security-guide/remediation_functions

populate var_auditd_disk_full_action

replace_or_append /etc/audit/auditd.conf '^disk_full_action' "$var_auditd_disk_full_action" "@CCENUM@"
