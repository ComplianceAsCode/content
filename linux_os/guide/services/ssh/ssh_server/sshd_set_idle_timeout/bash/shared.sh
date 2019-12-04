# platform = multi_platform_fedora,multi_platform_ol,multi_platform_rhel,multi_platform_rhv,multi_platform_sle,multi_platform_wrlinux
. /usr/share/scap-security-guide/remediation_functions
populate sshd_idle_timeout_value

replace_or_append '/etc/ssh/sshd_config' '^ClientAliveInterval' $sshd_idle_timeout_value '@CCENUM@' '%s %s'
