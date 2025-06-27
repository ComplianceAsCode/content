# platform = Red Hat Virtualization 4,multi_platform_ol,multi_platform_rhel,multi_platform_sle,multi_platform_slmicro,multi_platform_almalinux

{{% if product == 'slmicro6' %}}
LOGIN_DEFS_PATH=/usr/etc/login.defs
{{% else %}}
LOGIN_DEFS_PATH=/etc/login.defs
{{% endif %}}

{{{ bash_instantiate_variables("var_accounts_fail_delay") }}}

{{{ bash_replace_or_append("$LOGIN_DEFS_PATH", '^FAIL_DELAY', "$var_accounts_fail_delay", '%s %s', cce_identifiers=cce_identifiers) }}}
