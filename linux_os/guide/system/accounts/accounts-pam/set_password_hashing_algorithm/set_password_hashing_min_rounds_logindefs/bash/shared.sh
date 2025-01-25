# platform = multi_platform_all

{{{ bash_instantiate_variables("var_password_hashing_min_rounds_login_defs") }}}

config_file="/etc/login.defs"
current_min_rounds=$(grep -Po '^\s*SHA_CRYPT_MIN_ROUNDS\s+\K\d+' "$config_file")
current_max_rounds=$(grep -Po '^\s*SHA_CRYPT_MAX_ROUNDS\s+\K\d+' "$config_file")

if [[ -z "$current_min_rounds" || "$current_min_rounds" -le "$var_password_hashing_min_rounds_login_defs" ]]; then
    {{{ set_config_file(path="/etc/login.defs",
                parameter="SHA_CRYPT_MIN_ROUNDS",
                value="$var_password_hashing_min_rounds_login_defs",
                separator=" ",
                separator_regex="\s*") | indent(4) }}}
fi

if [[ -n "$current_max_rounds" && "$current_max_rounds" -le "$var_password_hashing_min_rounds_login_defs" ]]; then
    {{{ set_config_file(path="/etc/login.defs",
                    parameter="SHA_CRYPT_MAX_ROUNDS",
                    value="$var_password_hashing_min_rounds_login_defs",
                    separator=" ",
                    separator_regex="\s*") | indent(4) }}}
fi
