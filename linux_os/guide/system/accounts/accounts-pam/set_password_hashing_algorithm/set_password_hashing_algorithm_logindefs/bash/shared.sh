# platform = multi_platform_all

{{% if product == 'slmicro6' %}}
LOGIN_DEFS_PATH=/usr/etc/login.defs
{{% else %}}
LOGIN_DEFS_PATH=/etc/login.defs
{{% endif %}}

{{{ bash_instantiate_variables("var_password_hashing_algorithm") }}}

# Allow multiple algorithms, but choose the first one for remediation
#
var_password_hashing_algorithm="$(echo $var_password_hashing_algorithm | cut -d \| -f 1)"

{{{ bash_replace_or_append("$LOGIN_DEFS_PATH", '^ENCRYPT_METHOD', "$var_password_hashing_algorithm", '%s %s', cce_identifiers=cce_identifiers) }}}
