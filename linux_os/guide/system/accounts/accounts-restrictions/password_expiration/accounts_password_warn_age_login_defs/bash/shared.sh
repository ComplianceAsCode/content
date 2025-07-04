# platform = multi_platform_all

{{{ bash_instantiate_variables("var_accounts_password_warn_age_login_defs") }}}
{{{ bash_replace_or_append(login_defs_path, '^PASS_WARN_AGE', "$var_accounts_password_warn_age_login_defs", '%s %s', cce_identifiers=cce_identifiers) }}}
