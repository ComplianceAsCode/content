# platform = Red Hat Enterprise Linux 7,Oracle Linux 7

{{{ set_config_file(path="/etc/hosts.deny", parameter="ALL:", value="ALL", create=true, insert_after="EOF", insert_before="", insensitive=true, separator=" ", separator_regex="\s\+", prefix_regex="^\s*") }}}
