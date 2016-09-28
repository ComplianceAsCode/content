# platform = multi_platform_rhel
#
# Include source function library.
. /usr/share/scap-security-guide/remediation_functions
populate var_selinux_state

replace_or_append '/etc/sysconfig/selinux' '^SELINUX=' $var_selinux_state '$CCENUM' '%s=%s'
