# platform = multi_platform_rhel
#
# Include source function library.
INCLUDE_SHARED_REMEDIATION_FUNCTIONS
populate var_selinux_state

replace_or_append '/etc/sysconfig/selinux' '^SELINUX=' $var_selinux_state '$CCENUM' '%s=%s'
