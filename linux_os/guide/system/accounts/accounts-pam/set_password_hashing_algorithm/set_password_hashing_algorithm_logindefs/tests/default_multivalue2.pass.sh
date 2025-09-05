#!/bin/bash
# variables = var_password_hashing_algorithm=good_value1|good_value2

if grep -q "^ENCRYPT_METHOD" /etc/login.defs; then
	sed -i "s/^ENCRYPT_METHOD\b.*/ENCRYPT_METHOD good_value1/" /etc/login.defs
else
	echo "ENCRYPT_METHOD good_value1" >> /etc/login.defs
fi
