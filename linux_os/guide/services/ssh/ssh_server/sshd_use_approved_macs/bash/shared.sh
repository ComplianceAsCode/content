# platform = Red Hat Enterprise Linux 7,Oracle Linux 7,multi_platform_rhv

# Include source function library.
. /usr/share/scap-security-guide/remediation_functions

populate sshd_approved_macs

replace_or_append '/etc/ssh/sshd_config' '^MACs' "$sshd_approved_macs" '@CCENUM@' '%s %s'
