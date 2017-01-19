# platform = multi_platform_rhel, multi_platform_fedora

# Include source function library.
. $SHARED_REMEDIATION_FUNCTIONS

replace_or_append '/etc/ssh/sshd_config' '^IgnoreRhosts' 'yes' '$CCENUM' '%s %s'
