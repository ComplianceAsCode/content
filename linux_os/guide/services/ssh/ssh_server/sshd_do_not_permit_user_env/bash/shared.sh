# platform = Red Hat Enterprise Linux 7,Red Hat Enterprise Linux 8

# Include source function library.
. /usr/share/scap-security-guide/remediation_functions

replace_or_append '/etc/ssh/sshd_config' '^PermitUserEnvironment' 'no' '@CCENUM@' '%s %s'
