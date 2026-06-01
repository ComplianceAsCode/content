#!/bin/bash
# platform = SUSE Linux Enterprise 16
# variables = var_accounts_password_warn_age_login_defs=7

if [ -e {{{ login_defs_drop_in_path }}} ] ; then
    rm {{{ login_defs_drop_in_path }}}
fi
{{{ bash_copy_distro_defaults(login_defs_defaults_path, login_defs_path) }}}
if grep -q "^PASS_WARN_AGE" {{{ login_defs_path }}} ; then
    sed -i "s/PASS_WARN_AGE.*/PASS_WARN_AGE 7/g" {{{ login_defs_path }}}
else
    echo "PASS_WARN_AGE 7" >> {{{ login_defs_path }}}
fi
echo "PASS_WARN_AGE 0" >> "/etc/login.defs.d/user.dropin.defs"
