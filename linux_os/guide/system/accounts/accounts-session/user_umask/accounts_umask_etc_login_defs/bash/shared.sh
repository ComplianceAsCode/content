# platform = multi_platform_all

{{{ bash_instantiate_variables("var_accounts_user_umask") }}}

{{% if product in [ 'slmicro6', 'sle15', 'sle16' ] %}}
{{{ bash_login_defs("UMASK", "$var_accounts_user_umask", cce_identifiers=cce_identifiers) }}}
{{% else %}}
{{{ bash_replace_or_append(login_defs_path, '^UMASK', "$var_accounts_user_umask", '%s %s', cce_identifiers=cce_identifiers) }}}
{{% endif %}}
