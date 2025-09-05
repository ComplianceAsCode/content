# platform = multi_platform_all

{{{ bash_instantiate_variables("var_accounts_minimum_age_login_defs") }}}
{{{ bash_replace_or_append(login_defs_path, '^PASS_MIN_DAYS', "$var_accounts_minimum_age_login_defs", '%s %s', cce_identifiers=cce_identifiers) }}}
