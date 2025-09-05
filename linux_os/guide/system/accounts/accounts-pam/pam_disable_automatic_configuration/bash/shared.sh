# platform = multi_platform_sle,multi_platform_slmicro

{{% call iterate_over_find_output("link", '/etc/pam.d/ -type l -iname "common-*"') -%}}
target=$(readlink -f "$link")
cp -p --remove-destination "$target" "$link"
{{%- endcall %}}
