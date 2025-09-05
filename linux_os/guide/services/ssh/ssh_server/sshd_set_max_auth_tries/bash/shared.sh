# platform = multi_platform_wrlinux,multi_platform_rhel,multi_platform_fedora,multi_platform_ol,multi_platform_rhv,multi_platform_sle

# Include source function library.
. /usr/share/scap-security-guide/remediation_functions

populate sshd_max_auth_tries_value

{{{ bash_sshd_config_set(parameter="MaxAuthTries", value="$sshd_max_auth_tries_value") }}}
