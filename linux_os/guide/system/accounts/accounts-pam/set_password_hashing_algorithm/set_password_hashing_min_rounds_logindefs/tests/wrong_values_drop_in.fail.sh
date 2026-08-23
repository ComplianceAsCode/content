#!/bin/bash
# platform = SUSE Linux Enterprise 16
# variables = var_password_hashing_min_rounds_login_defs=5000

if [ -e {{{ login_defs_drop_in_path }}} ] ; then
    rm {{{ login_defs_drop_in_path }}}
fi
{{{ bash_copy_distro_defaults(login_defs_defaults_path, login_defs_path) }}}

if grep -q "^SHA_CRYPT_MIN_ROUNDS" {{{ login_defs_path }}} ; then
    sed -i "s/SHA_CRYPT_MIN_ROUNDS.*/SHA_CRYPT_MIN_ROUNDS 5000/g" {{{ login_defs_path }}}
else
    echo "SHA_CRYPT_MIN_ROUNDS 5000" >> {{{ login_defs_path }}}
fi
echo "SHA_CRYPT_MIN_ROUNDS 4999" >> {{{ login_defs_drop_in_path }}}

if grep -q "^SHA_CRYPT_MAX_ROUNDS" {{{ login_defs_path }}} ; then
    sed -i "s/SHA_CRYPT_MAX_ROUNDS.*/SHA_CRYPT_MAX_ROUNDS 5000/g" {{{ login_defs_path }}}
else
    echo "SHA_CRYPT_MAX_ROUNDS 5000" >> {{{ login_defs_path }}}
fi
echo "SHA_CRYPT_MAX_ROUNDS 4999" >> {{{ login_defs_drop_in_path }}}
