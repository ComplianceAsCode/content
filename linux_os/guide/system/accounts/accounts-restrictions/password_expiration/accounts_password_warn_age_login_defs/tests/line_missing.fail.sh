#!/bin/bash

if [ -e {{{ login_defs_drop_in_path }}} ] ; then
    rm {{{ login_defs_drop_in_path }}}
fi
{{{ bash_copy_distro_defaults(login_defs_defaults_path, login_defs_path) }}}
sed -i "/PASS_WARN_AGE.*/d" {{{ login_defs_path }}}
