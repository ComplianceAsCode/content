# platform = multi_platform_all

{{% if product == 'slmicro6' %}}
LOGIN_DEFS_PATH=/usr/etc/login.defs
{{% else %}}
LOGIN_DEFS_PATH=/etc/login.defs
{{% endif %}}

{{{ set_config_file("$LOGIN_DEFS_PATH", "CREATE_HOME", "yes", create=true, insert_after="", insert_before="^\s*CREATE_HOME", insensitive=true, rule_id=rule_id) }}}
