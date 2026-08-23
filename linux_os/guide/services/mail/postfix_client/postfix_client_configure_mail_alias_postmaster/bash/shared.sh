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
                    separator_regex="\s*:\s*", rule_id=rule_id) }}}

if [ -f /usr/bin/newaliases ]; then
    newaliases
fi
