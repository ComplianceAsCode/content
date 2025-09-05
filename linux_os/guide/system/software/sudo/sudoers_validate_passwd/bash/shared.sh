# platform = multi_platform_all

{{{ set_config_file(path="/etc/sudoers", parameter="Defaults !targetpw", value="", create=true, insensitive=false, separator="", separator_regex="", prefix_regex="") }}}
{{{ set_config_file(path="/etc/sudoers", parameter="Defaults !rootpw", value="", create=true, insensitive=false, separator="", separator_regex="", prefix_regex="") }}}
{{{ set_config_file(path="/etc/sudoers", parameter="Defaults !runaspw", value="", create=true, insensitive=false, separator="", separator_regex="", prefix_regex="") }}}
