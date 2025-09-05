#!/bin/bash
# packages = fapolicyd
# remediation = none

{{{ bash_shell_file_set("/etc/fapolicyd/fapolicyd.conf", "permissive", "1", "true") }}}

if [ -f /etc/fapolicyd/compiled.rules ]; then
    active_rules_file="/etc/fapolicyd/compiled.rules"
else
    active_rules_file="/etc/fapolicyd/fapolicyd.rules"
fi

truncate -s 0 $active_rules_file

echo "allow exe=/usr/bin/python3.7 : ftype=text/x-python" >> $active_rules_file
echo "deny perm=any all : all" >> $active_rules_file

{{{ bash_shell_file_set("/etc/fapolicyd/fapolicyd.conf", "permissive", "0", "true") }}}
