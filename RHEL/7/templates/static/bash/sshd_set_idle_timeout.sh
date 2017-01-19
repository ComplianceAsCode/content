# platform = Red Hat Enterprise Linux 7
INCLUDE_SHARED_REMEDIATION_FUNCTIONS
populate sshd_idle_timeout_value

replace_or_append '/etc/ssh/sshd_config' '^ClientAliveInterval' $sshd_idle_timeout_value '$CCENUM' '%s %s'
