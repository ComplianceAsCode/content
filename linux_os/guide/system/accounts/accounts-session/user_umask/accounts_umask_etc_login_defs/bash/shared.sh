# platform = multi_platform_all

{{% if product == 'slmicro6' %}}
LOGIN_DEFS_PATH=/usr/etc/login.defs
{{% else %}}
LOGIN_DEFS_PATH=/etc/login.defs
{{% endif %}}

{{{ bash_instantiate_variables("var_accounts_user_umask") }}}

{{{ bash_replace_or_append("$LOGIN_DEFS_PATH", '^UMASK', "$var_accounts_user_umask", '%s %s', cce_identifiers=cce_identifiers) }}}
