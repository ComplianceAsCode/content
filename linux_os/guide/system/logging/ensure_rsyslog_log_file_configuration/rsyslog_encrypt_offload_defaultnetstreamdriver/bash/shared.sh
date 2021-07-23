#!/bin/bash
# platform = Red Hat Enterprise Linux 8,multi_platform_fedora
{{{ set_config_file(path="/etc/rsyslog.d/encrypt.conf",
                    parameter="\$DefaultNetstreamDriver", value="gtls", create=true, separator=" ", separator_regex=" ")
}}}
