# platform = multi_platform_all

{{{ bash_instantiate_variables("var_password_hashing_algorithm") }}}
{{{ bash_replace_or_append('/etc/login.defs', '^ENCRYPT_METHOD', "$var_password_hashing_algorithm", '%s %s') }}}
