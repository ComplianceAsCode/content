#!/bin/bash
# platform = SUSE Linux Enterprise 16
# variables = var_password_hashing_algorithm=SHA512

if [ -e {{{ login_defs_drop_in_path }}} ] ; then
    rm {{{ login_defs_drop_in_path }}}
fi
{{{ bash_copy_distro_defaults(login_defs_defaults_path, login_defs_path) }}}
if grep -q "^ENCRYPT_METHOD" {{{ login_defs_path }}} ; then
    sed -i "s/ENCRYPT_METHOD.*/ENCRYPT_METHOD SHA512/g" {{{ login_defs_path }}}
else
    echo "ENCRYPT_METHOD SHA512" >> {{{ login_defs_path }}}
fi
echo "ENCRYPT_METHOD MD5" >> "/etc/login.defs.d/user.dropin.defs"
