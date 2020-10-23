#!/bin/bash

# Make sure ENCRYPT_METHOD is SHA512
if grep -q "^ENCRYPT_METHOD" /etc/login.defs; then
	sed -i "s/^ENCRYPT_METHOD\b.*/ENCRYPT_METHOD SHA512/" /etc/login.defs
else
	echo "ENCRYPT_METHOD SHA512" >> /etc/login.defs
fi
