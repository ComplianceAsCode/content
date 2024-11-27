#!/bin/bash
# variables = var_password_hashing_algorithm=YESCRYPT

# Make sure ENCRYPT_METHOD is YESCRYPT
if grep -q "^ENCRYPT_METHOD" /etc/login.defs; then
	sed -i "s/^ENCRYPT_METHOD\b.*/ENCRYPT_METHOD YESCRYPT/" /etc/login.defs
else
	echo "ENCRYPT_METHOD YESCRYPT" >> /etc/login.defs
fi
