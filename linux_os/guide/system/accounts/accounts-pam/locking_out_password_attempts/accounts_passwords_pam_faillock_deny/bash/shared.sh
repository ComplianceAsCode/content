# platform = multi_platform_wrlinux,multi_platform_rhel,multi_platform_fedora,multi_platform_ol,multi_platform_rhv,multi_platform_sle
. /usr/share/scap-security-guide/remediation_functions
{{{ bash_instantiate_variables("var_accounts_passwords_pam_faillock_deny") }}}

{{{ bash_set_faillock_option("deny", "$var_accounts_passwords_pam_faillock_deny") }}}
