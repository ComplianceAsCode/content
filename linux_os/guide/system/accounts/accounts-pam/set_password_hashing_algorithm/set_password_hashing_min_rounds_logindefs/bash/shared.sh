# platform = multi_platform_all

{{{ bash_instantiate_variables("var_password_hashing_min_rounds_login_defs") }}}

{{% if product == [ 'sle16', 'slmicro6' ] %}}
{{% set login_defs_d_config_dir = "/".join(login_defs_drop_in_path.split("/")[:-1]) ~ "/*.defs" %}}

min_rounds_login_defs=$(grep -Po '^\s*SHA_CRYPT_MIN_ROUNDS\s+\K\d+' {{{ login_defs_d_config_dir }}})
if [[ -z "$min_rounds_login_defs" ]]; then
    min_rounds_login_defs=$(grep -Po '^\s*SHA_CRYPT_MIN_ROUNDS\s+\K\d+' {{{ login_defs_path }}})
fi
if [[ -z "$min_rounds_login_defs" || "$min_rounds_login_defs" -le "$var_password_hashing_min_rounds_login_defs" ]]; then
    {{{ bash_login_defs("SHA_CRYPT_MIN_ROUNDS", "$var_password_hashing_min_rounds_login_defs", cce_identifiers=cce_identifiers) }}}
fi

max_rounds_login_defs=$(grep -Po '^\s*SHA_CRYPT_MAX_ROUNDS\s+\K\d+' {{{ login_defs_d_config_dir }}})
if [[ -z "$max_rounds_login_defs" ]]; then
    max_rounds_login_defs=$(grep -Po '^\s*SHA_CRYPT_MAX_ROUNDS\s+\K\d+' {{{ login_defs_path }}})
fi
if [[ -z "$max_rounds_login_defs" || "$max_rounds_login_defs" -le "$var_password_hashing_min_rounds_login_defs" ]]; then
    {{{ bash_login_defs("SHA_CRYPT_MAX_ROUNDS", "$var_password_hashing_min_rounds_login_defs", cce_identifiers=cce_identifiers) }}}
fi

{{% else %}}

config_file={{{ login_defs_path }}}
current_min_rounds=$(grep -Po '^\s*SHA_CRYPT_MIN_ROUNDS\s+\K\d+' "$config_file")
current_max_rounds=$(grep -Po '^\s*SHA_CRYPT_MAX_ROUNDS\s+\K\d+' "$config_file")

if [[ -z "$current_min_rounds" || "$current_min_rounds" -le "$var_password_hashing_min_rounds_login_defs" ]]; then
    {{{ set_config_file(path=login_defs_path,
                parameter="SHA_CRYPT_MIN_ROUNDS",
                value="$var_password_hashing_min_rounds_login_defs",
                separator=" ",
                separator_regex="\s*", rule_id=rule_id) | indent(4) }}}
fi

if [[ -n "$current_max_rounds" && "$current_max_rounds" -le "$var_password_hashing_min_rounds_login_defs" ]]; then
    {{{ set_config_file(path=login_defs_path,
                    parameter="SHA_CRYPT_MAX_ROUNDS",
                    value="$var_password_hashing_min_rounds_login_defs",
                    separator=" ",
                    separator_regex="\s*", rule_id=rule_id) | indent(4) }}}
fi
{{% endif %}}
