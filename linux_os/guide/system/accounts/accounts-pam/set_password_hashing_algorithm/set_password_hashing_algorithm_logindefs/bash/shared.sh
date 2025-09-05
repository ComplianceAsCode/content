# platform = multi_platform_all

{{{ bash_instantiate_variables("var_password_hashing_algorithm") }}}

# Allow multiple algorithms, but choose the first one for remediation
#
var_password_hashing_algorithm="$(echo $var_password_hashing_algorithm | cut -d \| -f 1)"

{{{ bash_replace_or_append(login_defs_path, '^ENCRYPT_METHOD', "$var_password_hashing_algorithm", '%s %s', cce_identifiers=cce_identifiers) }}}
