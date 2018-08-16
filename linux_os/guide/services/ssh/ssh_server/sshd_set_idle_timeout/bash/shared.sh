# platform = multi_platform_rhel, multi_platform_fedora
. /usr/share/scap-security-guide/remediation_functions
populate sshd_idle_timeout_value

replace_or_append '/etc/ssh/sshd_config' '^ClientAliveInterval' $sshd_idle_timeout_value '@CCENUM@' '%s %s'
