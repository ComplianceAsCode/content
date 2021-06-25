#!/bin/bash

echo "max-test-user:x:10020:10020:Test User for Password Expiration:/:/sbin/nologin" >> /etc/passwd
echo "max-test-user:!!:18648:1:60:::" >> /etc/shadow
