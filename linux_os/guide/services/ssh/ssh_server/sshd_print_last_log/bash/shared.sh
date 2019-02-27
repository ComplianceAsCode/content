# platform = multi_platform_rhel,multi_platform_ol,multi_platform_rhv,multi_platform_sle

# Include source function library.
. /usr/share/scap-security-guide/remediation_functions

replace_or_append '/etc/ssh/sshd_config' '^PrintLastLog' 'yes' '@CCENUM@' '%s %s'
