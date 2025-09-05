# platform = multi_platform_all
# reboot = false
# strategy = configure
# complexity = low
# disruption = low

{{{ set_config_file(path="/etc/aliases",
                    parameter="postmaster",
                    value="root",
                    create=true,
                    separator=": ",
                    separator_regex="\s*:\s*") }}}

if [ -f /usr/bin/newaliases ]; then
    newaliases
fi
