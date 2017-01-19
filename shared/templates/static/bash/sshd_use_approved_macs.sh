# platform = multi_platform_rhel

# Include source function library.
. $SHARED_REMEDIATION_FUNCTIONS

replace_or_append '/etc/ssh/sshd_config' '^MACs' 'hmac-sha2-512,hmac-sha2-256,hmac-sha1' '$CCENUM' '%s %s'
