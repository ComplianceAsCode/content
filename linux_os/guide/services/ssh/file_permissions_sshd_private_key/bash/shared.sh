# platform=multi_platform_all

{{% set dedicated_ssh_groupname = groups.get("dedicated_ssh_keyowner", {}).get("name") %}}
{{% macro keyfile_owned_by(groupname) -%}}
test root:{{{ groupname }}} = "$(stat -c "%U:%G" "$keyfile")"
{{%- endmacro -%}}

for keyfile in /etc/ssh/*_key; do
    test -f "$keyfile" || continue
    if {{{ keyfile_owned_by("root") }}}; then
    {{% if product in ["sle12", "sle15", "slmicro5"] %}}
	chmod u-xs,g-xws,o-xwrt "$keyfile"
    {{% else %}}
	chmod u-xs,g-xwrs,o-xwrt "$keyfile"
    {{% endif %}}
    {{% if dedicated_ssh_groupname -%}}
    elif {{{ keyfile_owned_by(dedicated_ssh_groupname) }}}; then
	chmod u-xs,g-xws,o-xwrt "$keyfile"
    {{%- endif %}}
    else
        echo "Key-like file '$keyfile' is owned by an unexpected user:group combination"
    fi
done
