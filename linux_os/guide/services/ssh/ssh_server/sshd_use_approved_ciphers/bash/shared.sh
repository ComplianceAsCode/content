# platform = multi_platform_wrlinux,Red Hat Enterprise Linux 7,Red Hat Enterprise Linux 6,Oracle Linux 7

# Include source function library.
. /usr/share/scap-security-guide/remediation_functions

populate sshd_approved_ciphers

replace_or_append '/etc/ssh/sshd_config' '^Ciphers' "$sshd_approved_ciphers" '@CCENUM@' '%s %s'
