# platform = multi_platform_rhel

# Include source function library.
. /usr/share/scap-security-guide/remediation_functions

replace_or_append '/etc/ssh/sshd_config' '^StrictModes' 'yes' '$CCENUM' '%s %s'
