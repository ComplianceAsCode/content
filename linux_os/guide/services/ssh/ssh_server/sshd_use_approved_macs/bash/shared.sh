# platform = multi_platform_rhel,multi_platform_fedora,multi_platform_ol

# Include source function library.
. /usr/share/scap-security-guide/remediation_functions

populate sshd_approved_macs

replace_or_append '/etc/ssh/sshd_config' '^MACs' "$sshd_approved_macs" '@CCENUM@' '%s %s'
