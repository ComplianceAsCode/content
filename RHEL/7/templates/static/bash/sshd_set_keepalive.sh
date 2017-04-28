# platform = Red Hat Enterprise Linux 7

# Include source function library.
. /usr/share/scap-security-guide/remediation_functions

replace_or_append '/etc/ssh/sshd_config' '^ClientAliveCountMax' '0' '@CCENUM@' '%s %s'
