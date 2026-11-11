#!/bin/bash

{{{ bash_copy_distro_defaults(login_defs_defaults_path, login_defs_path) }}}

if getent passwd sysuser 2>/dev/null ; then
    userdel -r sysuser
fi
