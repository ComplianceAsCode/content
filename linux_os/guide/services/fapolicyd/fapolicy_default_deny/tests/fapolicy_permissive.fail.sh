#!/bin/bash
# packages = fapolicyd
# remediation = none

{{{ bash_shell_file_set("/etc/fapolicyd/fapolicyd.conf","permissive","0") }}}
