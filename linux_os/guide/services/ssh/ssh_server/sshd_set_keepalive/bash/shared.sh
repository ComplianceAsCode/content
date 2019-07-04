# platform = multi_platform_wrlinux,multi_platform_rhel,multi_platform_fedora,multi_platform_ol,multi_platform_rhv

# Include source function library.
. /usr/share/scap-security-guide/remediation_functions

populate var_sshd_set_keepalive

replace_or_append '/etc/ssh/sshd_config' '^ClientAliveCountMax' "$var_sshd_set_keepalive" '@CCENUM@' '%s %s'
