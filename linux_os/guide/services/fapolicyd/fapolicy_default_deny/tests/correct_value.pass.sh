#!/bin/bash
# packages = fapolicyd
# remediation = none

{{{ bash_shell_file_set("/etc/fapolicyd/fapolicyd.conf","permissive","1") }}}

truncate -s 0 /etc/fapolicyd/fapolicyd.rules

echo "allow exe=/usr/bin/python3.7 : ftype=text/x-python" > /etc/fapolicyd/fapolicyd.rules
echo "deny perm=any all : all" > /etc/fapolicyd/fapolicyd.rules

{{{ bash_shell_file_set("/etc/fapolicyd/fapolicyd.conf","permissive","0") }}}
