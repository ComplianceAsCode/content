# platform = Red Hat Enterprise Linux 7

# Include source function library.
. /usr/share/scap-security-guide/remediation_functions

populate var_audispd_disk_full_action

replace_or_append /etc/audisp/audisp-remote.conf '^disk_full_action' "$var_audispd_disk_full_action" "@CCENUM@"
