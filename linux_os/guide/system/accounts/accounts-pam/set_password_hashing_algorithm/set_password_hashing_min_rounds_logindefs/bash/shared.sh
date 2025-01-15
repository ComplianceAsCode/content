# platform = multi_platform_all

{{{ bash_instantiate_variables("var_password_hashing_min_rounds_login_defs") }}}

{{{ set_config_file(path="/etc/login.defs",
                    parameter="SHA_CRYPT_MIN_ROUNDS",
                    value="$var_password_hashing_min_rounds_login_defs",
                    separator=" ",
                    separator_regex="\s*") }}}
