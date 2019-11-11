# platform = multi_platform_wrlinux,multi_platform_rhel,multi_platform_fedora,multi_platform_ol,multi_platform_rhv
. /usr/share/scap-security-guide/remediation_functions
populate var_accounts_passwords_pam_faillock_deny

{{{ bash_set_faillock_option("deny", "$var_accounts_passwords_pam_faillock_deny") }}}
