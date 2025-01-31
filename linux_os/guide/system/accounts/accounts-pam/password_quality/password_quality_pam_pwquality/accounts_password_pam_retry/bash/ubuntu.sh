# platform = multi_platform_ubuntu

{{{ bash_instantiate_variables("var_password_pam_retry") }}}

{{{ bash_pam_pwquality_enable() }}}
{{{ bash_pam_pwquality_parameter_value('retry', "$var_password_pam_retry") }}}
