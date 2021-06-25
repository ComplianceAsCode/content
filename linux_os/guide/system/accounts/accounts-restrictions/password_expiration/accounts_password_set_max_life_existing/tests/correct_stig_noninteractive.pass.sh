#!/bin/bash

# Remove noninteractive users
sed -i '/^\S\+:x:[0-9]\{4,9\}/d' /etc/passwd
# Noninteractive users are a pass
echo "max-test-user:x:540:540:Test User for Password Expiration:/:/sbin/nologin" >> /etc/passwd
echo "max-test-user:!!:18648:1::::" >> /etc/shadow

