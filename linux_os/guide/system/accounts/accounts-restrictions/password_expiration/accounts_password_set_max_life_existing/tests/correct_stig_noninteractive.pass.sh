#!/bin/bash

# Remove noninteractive users
sed -i '/:\(\*\|!!\):/!d' /etc/shadow
# Noninteractive users are a pass
echo "max-test-user:x:540:540:Test User for Password Expiration:/:/sbin/nologin" >> /etc/passwd
echo "max-test-user:!!:18648:1::::" >> /etc/shadow

