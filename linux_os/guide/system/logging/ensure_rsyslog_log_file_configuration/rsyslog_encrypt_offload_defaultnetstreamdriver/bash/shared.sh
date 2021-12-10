# platform = multi_platform_all
{{{ set_config_file(path="/etc/rsyslog.d/encrypt.conf",
                    parameter="\$DefaultNetstreamDriver", value="gtls", create=true, separator=" ", separator_regex=" ")
}}}
