# platform = multi_platform_all

{{%- macro delete_line_in_sudoers_d(line) %}}
if grep -x '^{{{line}}}$' /etc/sudoers; then
    sed -i "/{{{line}}}/d" /etc/sudoers \;
fi
if grep -x '^{{{line}}}$' /etc/sudoers.d/*; then
    find /etc/sudoers.d/ -type f -exec sed -i "/{{{line}}}/d" {} \;
fi
{{%- endmacro %}}

{{% if product in [ 'sle16', 'slmicro6'] %}}
{{{ bash_copy_distro_defaults("/usr/etc/sudoers", "/etc/sudoers") }}}
{{{ lineinfile_absent("/etc/sudoers", "^\s*@includedir\s*/usr/etc/sudoers\.d", sed_path_separator="#", rule_id=rule_id) }}}
{{% endif %}}

{{{- delete_line_in_sudoers_d("Defaults targetpw") }}}
{{{- delete_line_in_sudoers_d("Defaults rootpw") }}}
{{{- delete_line_in_sudoers_d("Defaults runaspw") }}}

{{{ set_config_file(path="/etc/sudoers", parameter="Defaults !targetpw", value="", create=true, insensitive=false, separator="", separator_regex="", prefix_regex="", rule_id=rule_id) }}}
{{{ set_config_file(path="/etc/sudoers", parameter="Defaults !rootpw", value="", create=true, insensitive=false, separator="", separator_regex="", prefix_regex="", rule_id=rule_id) }}}
{{{ set_config_file(path="/etc/sudoers", parameter="Defaults !runaspw", value="", create=true, insensitive=false, separator="", separator_regex="", prefix_regex="", rule_id=rule_id) }}}
