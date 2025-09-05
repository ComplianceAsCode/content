# platform = multi_platform_all

{{%- macro delete_line_in_sudoers_d(line) %}}
if grep -x '^{{{line}}}$' /etc/sudoers; then
    sed -i "/{{{line}}}/d" /etc/sudoers \;
fi
if grep -x '^{{{line}}}$' /etc/sudoers.d/*; then
    find /etc/sudoers.d/ -type f -exec sed -i "/{{{line}}}/d" {} \;
fi
{{%- endmacro %}}

{{{- delete_line_in_sudoers_d("Defaults targetpw") }}}
{{{- delete_line_in_sudoers_d("Defaults rootpw") }}}
{{{- delete_line_in_sudoers_d("Defaults runaspw") }}}

{{{ set_config_file(path="/etc/sudoers", parameter="Defaults !targetpw", value="", create=true, insensitive=false, separator="", separator_regex="", prefix_regex="") }}}
{{{ set_config_file(path="/etc/sudoers", parameter="Defaults !rootpw", value="", create=true, insensitive=false, separator="", separator_regex="", prefix_regex="") }}}
{{{ set_config_file(path="/etc/sudoers", parameter="Defaults !runaspw", value="", create=true, insensitive=false, separator="", separator_regex="", prefix_regex="") }}}
