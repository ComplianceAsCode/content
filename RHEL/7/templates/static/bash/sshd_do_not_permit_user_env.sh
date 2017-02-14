# platform = Red Hat Enterprise Linux 7

# Include source function library.
INCLUDE_SHARED_REMEDIATION_FUNCTIONS

replace_or_append '/etc/ssh/sshd_config' '^PermitUserEnvironment' 'no' '$CCENUM' '%s %s'
