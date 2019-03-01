# platform = multi_platform_sle

# Include source function library.
. /usr/share/scap-security-guide/remediation_functions

replace_or_append '/etc/ssh/sshd_config' '^Compression' 'delayed' '@CCENUM@' '%s %s'
