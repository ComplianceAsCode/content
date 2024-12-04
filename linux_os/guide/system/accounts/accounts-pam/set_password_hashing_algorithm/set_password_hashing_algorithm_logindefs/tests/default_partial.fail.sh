#!/bin/bash
# variables = var_password_hashing_algorithm=value1|value2

# test that partial match fails
if grep -q "^ENCRYPT_METHOD" /etc/login.defs; then
	sed -i "s/^ENCRYPT_METHOD\b.*/ENCRYPT_METHOD value/" /etc/login.defs
else
	echo "ENCRYPT_METHOD value" >> /etc/login.defs
fi
