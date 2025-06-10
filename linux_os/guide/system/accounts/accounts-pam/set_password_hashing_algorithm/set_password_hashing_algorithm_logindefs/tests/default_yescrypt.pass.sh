#!/bin/bash
# variables = var_password_hashing_algorithm=YESCRYPT

{{% if product == 'slmicro6' %}}
LOGIN_DEFS_PATH=/usr/etc/login.defs
{{% else %}}
LOGIN_DEFS_PATH=/etc/login.defs
{{% endif %}}

# Make sure ENCRYPT_METHOD is YESCRYPT
if grep -q "^ENCRYPT_METHOD" "$LOGIN_DEFS_PATH"; then
	sed -i "s/^ENCRYPT_METHOD\b.*/ENCRYPT_METHOD YESCRYPT/" "$LOGIN_DEFS_PATH"
else
	echo "ENCRYPT_METHOD YESCRYPT" >> "$LOGIN_DEFS_PATH"
fi
