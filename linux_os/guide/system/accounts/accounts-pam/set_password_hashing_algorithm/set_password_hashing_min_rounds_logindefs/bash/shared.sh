# platform = multi_platform_ol

{{{ set_config_file(path="/etc/login.defs",
                    parameter="SHA_CRYPT_MIN_ROUNDS",
                    value="5000",
                    separator=" ",
                    separator_regex="\s*") }}}

