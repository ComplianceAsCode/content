# platform = multi_platform_rhel,multi_platform_ol

# Include source function library.
. /usr/share/scap-security-guide/remediation_functions

replace_or_append '/etc/ssh/sshd_config' '^Protocol' '2' '@CCENUM@' '%s %s'
