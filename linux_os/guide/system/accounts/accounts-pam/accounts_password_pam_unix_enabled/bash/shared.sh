# platform = multi_platform_ubuntu

{{% if 'ubuntu' in product or 'debian' in product %}}
    {{{ bash_pam_unix_enable() }}}
{{% else %}}
    {{{ bash_ensure_pam_module_line_unix_enable(["password-auth", "system-auth"], ["auth", "account", "password", "session"]) }}}
{{% endif %}}
