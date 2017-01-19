# platform = Red Hat Enterprise Linux 7

# Include source function library.
. $SHARED_REMEDIATION_FUNCTIONS

replace_or_append '/etc/ssh/sshd_config' '^ClientAliveCountMax' '0' '$CCENUM' '%s %s'
