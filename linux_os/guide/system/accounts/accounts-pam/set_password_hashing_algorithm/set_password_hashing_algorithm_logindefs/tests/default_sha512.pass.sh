#!/bin/bash
# variables = var_password_hashing_algorithm=SHA512

# Make sure ENCRYPT_METHOD is SHA512
if grep -q "^ENCRYPT_METHOD" {{{ login_defs_path }}}; then
	sed -i "s/^ENCRYPT_METHOD\b.*/ENCRYPT_METHOD SHA512/" {{{ login_defs_path }}}
else
	echo "ENCRYPT_METHOD SHA512" >> {{{ login_defs_path }}}
fi
