# platform = multi_platform_rhel,multi_platform_fedora,multi_platform_ol
#
# Include source function library.
. /usr/share/scap-security-guide/remediation_functions
populate var_selinux_policy_name

replace_or_append '/etc/sysconfig/selinux' '^SELINUXTYPE=' $var_selinux_policy_name '@CCENUM@' '%s=%s'
