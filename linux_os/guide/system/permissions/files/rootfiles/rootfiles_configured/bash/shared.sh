# platform = multi_platform_all
# reboot = false
# strategy = configure
# complexity = low
# disruption = low

{{%- set files = ['bash_logout', 'bash_profile', 'bashrc', 'cshrc', 'tcshrc', ] %}}

{{%- for file in files %}}
    {{% set dest_path = '/root/.' ~ file -%}}
    {{% set source_path = '/usr/share/rootfiles/.' ~ file -%}}
    {{% set new_line = 'C ' ~ dest_path ~ ' 600 root root - '  ~ source_path  %}}
    {{{ set_config_file('/etc/tmpfiles.d/rootconf.conf', new_line, value="", create='yes', insert_after="", insert_before="", separator="", separator_regex="", prefix_regex="^\s*", sed_path_separator='#') -}}}
{{%- endfor %}}
