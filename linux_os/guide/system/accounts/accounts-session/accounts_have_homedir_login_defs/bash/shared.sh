# platform = multi_platform_all

{{% if product in [ 'slmicro6', 'sle15', 'sle16' ] %}}
{{{ bash_login_defs("CREATE_HOME", "yes", cce_identifiers=cce_identifiers) }}}
{{% else %}}
{{{ bash_replace_or_append(login_defs_path, '^CREATE_HOME', "yes", '%s %s', cce_identifiers=cce_identifiers) }}}
{{% endif %}}
