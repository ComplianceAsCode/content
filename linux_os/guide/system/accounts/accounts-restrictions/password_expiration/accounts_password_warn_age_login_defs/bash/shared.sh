# platform = multi_platform_all

{{{ bash_instantiate_variables("var_accounts_password_warn_age_login_defs") }}}
{{{ bash_replace_or_append('/etc/login.defs', '^PASS_WARN_AGE', "$var_accounts_password_warn_age_login_defs", '%s %s') }}}
