#!/bin/bash
# variables = var_password_hashing_algorithm=good_value1|good_value2

if grep -q "^ENCRYPT_METHOD" /etc/login.defs; then
	sed -i "s/^ENCRYPT_METHOD\b.*/ENCRYPT_METHOD wrong_value/" /etc/login.defs
else
	echo "ENCRYPT_METHOD wrong_value" >> /etc/login.defs
fi
