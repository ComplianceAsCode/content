#!/bin/bash
# variables = var_password_hashing_algorithm=SHA512

# Make sure ENCRYPT_METHOD is SHA256
if grep -q "^ENCRYPT_METHOD" {{{ login_defs_path }}}; then
	sed -i "s/^ENCRYPT_METHOD\b.*/ENCRYPT_METHOD SHA256/" {{{ login_defs_path }}}
else
	echo "ENCRYPT_METHOD SHA256" >> {{{ login_defs_path }}}
fi
