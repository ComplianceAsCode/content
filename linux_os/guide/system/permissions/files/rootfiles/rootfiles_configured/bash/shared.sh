# platform = multi_platform_all
# reboot = false
# strategy = configure
# complexity = low
# disruption = low

{{%- set files = ['bash_logout', 'bash_profile', 'bashrc', 'cshrc', 'tcshrc', ] %}}
{{%- set ns = namespace(contents="") %}}

{{%- for file in files %}}
    {{% set dest_path = '/root/.' ~ file -%}}
    {{% set source_path = '/usr/share/rootfiles/.' ~ file -%}}
    {{% set new_line = 'C ' ~ dest_path ~ ' 600 root root - '  ~ source_path ~ "\n"  -%}}
    find "/etc/tmpfiles.d/" -name "*.conf" -print0 | xargs -0 sed -i  "/C[[:space:]]*{{{ dest_path.replace('/', '\\/') }}}/d"
    {{%- set ns.contents = ns.contents ~ new_line -%}}
{{%- endfor %}}

{{{ bash_file_contents('/etc/tmpfiles.d/rootfiles.conf', ns.contents) }}}
