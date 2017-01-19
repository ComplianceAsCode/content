# platform = multi_platform_rhel
#
# Include source function library.
. $SHARED_REMEDIATION_FUNCTIONS
populate var_selinux_policy_name

replace_or_append '/etc/sysconfig/selinux' '^SELINUXTYPE=' $var_selinux_policy_name '$CCENUM' '%s=%s'
