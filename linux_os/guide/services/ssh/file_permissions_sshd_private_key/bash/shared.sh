# platform=multi_platform_all

{{% set dedicated_ssh_groupname = "ssh_keys" %}}

{{% macro keyfile_owned_by(groupname) -%}}
test root:{{{ groupname }}} = "$(stat -c "%U:%G" "$keyfile")"
{{%- endmacro -%}}

for keyfile in /etc/ssh/*_key; do
    test -f "$keyfile" || continue
    if {{{ keyfile_owned_by("root") }}}; then
	chmod u-xs,g-xwrs,o-xwrt "$keyfile"
    elif {{{ keyfile_owned_by(dedicated_ssh_groupname) }}}; then
	chmod u-xs,g-xws,o-xwrt "$keyfile"
    else
        echo "Key-like file '$keyfile' is owned by an unexpected user:group combination"
    fi
done
