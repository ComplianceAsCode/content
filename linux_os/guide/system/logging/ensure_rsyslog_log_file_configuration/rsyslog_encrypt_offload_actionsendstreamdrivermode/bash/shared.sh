# platform = multi_platform_all

{{{ set_config_file(path="/etc/rsyslog.d/encrypt.conf",
             parameter="\$ActionSendStreamDriverMode", value="1", create=true, separator=" ", separator_regex=" ")
}}}
