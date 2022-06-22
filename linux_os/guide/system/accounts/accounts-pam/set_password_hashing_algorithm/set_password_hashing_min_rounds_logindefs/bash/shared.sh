# platform = Oracle Linux 7,Oracle Linux 8

{{{ set_config_file(path="/etc/login.defs",
                    parameter="SHA_CRYPT_MIN_ROUNDS",
                    value="5000",
                    separator=" ",
                    separator_regex="\s*") }}}
