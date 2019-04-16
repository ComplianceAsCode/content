# platform = SUSE Linux Enterprise 12

# Include source function library.
. /usr/share/scap-security-guide/remediation_functions

replace_or_append '/etc/ssh/sshd_config' '^UsePrivilegeSeparation' 'yes' '@CCENUM@' '%s %s'
