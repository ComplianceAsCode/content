# platform = Red Hat Enterprise Linux 7

# Include source function library.
. $SHARED_REMEDIATION_FUNCTIONS

replace_or_append '/etc/ssh/sshd_config' '^Ciphers' 'aes128-ctr,aes192-ctr,aes256-ctr,aes128-cbc,3des-cbc,aes192-cbc,aes256-cbc' '$CCENUM' '%s %s'
