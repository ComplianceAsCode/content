# platform = SUSE Enterprise 12

# Include source function library.
. /usr/share/scap-security-guide/remediation_functions

replace_or_append '/etc/ssh/sshd_config' '^Banner' '/etc/issue' 'CCENUM' '%s %s'
