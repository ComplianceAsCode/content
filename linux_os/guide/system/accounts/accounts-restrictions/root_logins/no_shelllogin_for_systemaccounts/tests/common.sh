#!/bin/bash

{{% if product in ['opensuse16', 'sle16', 'slmicro6'] %}}
{{{ bash_copy_distro_defaults(login_defs_defaults_path, login_defs_path) }}}
{{% endif %}}

if getent passwd sysuser 2>/dev/null ; then
    userdel -r sysuser
fi
