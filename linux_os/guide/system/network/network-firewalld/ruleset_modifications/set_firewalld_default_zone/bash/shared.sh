# platform = multi_platform_rhel,multi_platform_ol,multi_platform_rhv

# Include source function library.
. /usr/share/scap-security-guide/remediation_functions

replace_or_append '/etc/firewalld/firewalld.conf' '^DefaultZone' "drop" '@CCENUM@' '%s %s'
