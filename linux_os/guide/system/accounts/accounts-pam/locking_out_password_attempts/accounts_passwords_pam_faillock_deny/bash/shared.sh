# platform = multi_platform_rhel,multi_platform_fedora,multi_platform_ol,multi_platform_rhv,multi_platform_sle,multi_platform_ubuntu

{{{ bash_instantiate_variables("var_accounts_passwords_pam_faillock_deny") }}}

{{{ bash_pam_faillock_enable() }}}
{{{ bash_pam_faillock_parameter_value("deny", "$var_accounts_passwords_pam_faillock_deny") }}}
