# platform = SUSE Linux Enterprise 12

# Include source function library.
. /usr/share/scap-security-guide/remediation_functions

replace_or_append '/etc/ssh/sshd_config' '^Ciphers' 'aes128-ctr,aes192-ctr,aes256-ctr' '@CCENUM@' '%s %s'
