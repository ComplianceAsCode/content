# platform = multi_platform_wrlinux,multi_platform_rhel,multi_platform_ol,multi_platform_rhv

# Include source function library.
. /usr/share/scap-security-guide/remediation_functions

populate var_sshd_disable_compression

replace_or_append '/etc/ssh/sshd_config' '^Compression' "$var_sshd_disable_compression" '@CCENUM@' '%s %s'
