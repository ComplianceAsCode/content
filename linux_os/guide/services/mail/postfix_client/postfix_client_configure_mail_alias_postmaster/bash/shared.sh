# platform = multi_platform_all

{{{ set_config_file(path="/etc/aliases",
                    parameter="postmaster",
                    value="root",
                    create=true,
                    separator=": ",
                    separator_regex="\s*:\s*") }}}

newaliases
