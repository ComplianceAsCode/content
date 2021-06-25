#!/bin/bash

# Remove noninteractive users
sed -i '/^\S\+:x:[0-9]\{4,9\}/d' /etc/passwd

# Noninteractive users are a pass
echo "nobody1:x:65535:65534:Test User for Password Expiration:/:/sbin/nologin" >> /etc/passwd
echo "nobody1:!!:18648:1::::" >> /etc/shadow

echo "nobody2:x:65534:65535:Test User for Password Expiration:/:/sbin/nologin" >> /etc/passwd
echo "nobody2:!!:18648:1::::" >> /etc/shadow
