#!/bin/bash

# Make sure ENCRYPT_METHOD is SHA256
if grep -q "^ENCRYPT_METHOD" /etc/login.defs; then
	sed -i "s/^ENCRYPT_METHOD\b.*/ENCRYPT_METHOD SHA256/" /etc/login.defs
else
	echo "ENCRYPT_METHOD SHA256" >> /etc/login.defs
fi
