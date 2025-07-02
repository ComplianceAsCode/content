#!/bin/bash
# variables = var_password_hashing_algorithm=YESCRYPT

# Make sure ENCRYPT_METHOD is YESCRYPT
if grep -q "^ENCRYPT_METHOD" {{{ login_defs_path }}}; then
	sed -i "s/^ENCRYPT_METHOD\b.*/ENCRYPT_METHOD YESCRYPT/" {{{ login_defs_path }}}
else
	echo "ENCRYPT_METHOD YESCRYPT" >> {{{ login_defs_path }}}
fi
