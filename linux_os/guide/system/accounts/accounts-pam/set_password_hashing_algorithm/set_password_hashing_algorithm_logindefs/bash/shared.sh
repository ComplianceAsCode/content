# platform = multi_platform_rhel,multi_platform_fedora,multi_platform_ol,multi_platform_rhv,multi_platform_sle,multi_platform_ubuntu

{{{ bash_instantiate_variables("var_password_hashing_algorithm") }}}
{{{ bash_replace_or_append('/etc/login.defs', '^ENCRYPT_METHOD', "$var_password_hashing_algorithm", '%s %s') }}}
