#!/bin/bash
# variables = var_password_hashing_algorithm=value1|value2

# test that partial match fails
if grep -q "^ENCRYPT_METHOD" {{{ login_defs_path }}}; then
	sed -i "s/^ENCRYPT_METHOD\b.*/ENCRYPT_METHOD value/" {{{ login_defs_path }}}
else
	echo "ENCRYPT_METHOD value" >> {{{ login_defs_path }}}
fi
