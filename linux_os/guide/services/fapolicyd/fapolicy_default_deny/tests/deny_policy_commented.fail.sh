#!/bin/bash
# packages = fapolicyd

if [ -f /etc/fapolicyd/compiled.rules ]; then
    active_rules_file="/etc/fapolicyd/compiled.rules"
else
    active_rules_file="/etc/fapolicyd/fapolicyd.rules"
fi

truncate -s 0 $active_rules_file
echo "allow exe=/usr/bin/python3.7 : ftype=text/x-python" >> $active_rules_file
echo "# deny perm=any all : all" >> $active_rules_file

{{{ set_config_file(path="/etc/fapolicyd/fapolicyd.conf",
                    parameter="permissive",
                    value="0",
                    create=true,
                    insensitive=true,
                    separator=" = ",
                    separator_regex="\s*=\s*",
                    prefix_regex="^\s*") }}}
