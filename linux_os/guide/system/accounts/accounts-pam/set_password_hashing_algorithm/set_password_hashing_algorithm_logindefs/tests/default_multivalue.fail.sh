#!/bin/bash
# variables = var_password_hashing_algorithm=good_value1|good_value2


if grep -q "^ENCRYPT_METHOD" {{{ login_defs_path }}}; then
	sed -i "s/^ENCRYPT_METHOD\b.*/ENCRYPT_METHOD wrong_value/" {{{ login_defs_path }}}
else
	echo "ENCRYPT_METHOD wrong_value" >> {{{ login_defs_path }}}
fi
