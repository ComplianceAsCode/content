# platform = multi_platform_rhel,multi_platform_ol,multi_platform_sle,multi_platform_rhv4
# reboot = false
# strategy = restrict
# complexity = low
# disruption = low

{{% call iterate_over_command_output("dir", "awk -F':' '{ if ($3 >= " ~ uid_min ~ " && $3 != " ~ nobody_uid ~ ") print $6}' /etc/passwd") -%}}
{{% call iterate_over_find_output("file", '$dir -maxdepth 1 -type f -name ".*"') -%}}
if [ "$(basename $file)" != ".bash_history" ]; then
    sed -i 's/^\(\s*umask\s*\)/#\1/g' "$file"
fi
{{%- endcall %}}
{{%- endcall %}}
