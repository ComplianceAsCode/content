# platform = multi_platform_all

{{{ bash_instantiate_variables("var_accounts_user_umask") }}}

{{{ bash_replace_or_append(login_defs_path, '^UMASK', "$var_accounts_user_umask", '%s %s', cce_identifiers=cce_identifiers) }}}
