# platform = multi_platform_fedora,multi_platform_rhel,multi_platform_rhv,multi_platform_sle,multi_platform_wrlinux,multi_platorm_ol
#
# Include source function library.
. /usr/share/scap-security-guide/remediation_functions
populate var_selinux_state

replace_or_append '/etc/sysconfig/selinux' '^SELINUX=' $var_selinux_state '@CCENUM@' '%s=%s'

fixfiles onboot
fixfiles -f relabel
