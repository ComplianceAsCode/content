#!/bin/bash
mkdir -p /etc/security/pwquality.conf.d
touch /etc/security/pwquality.conf.d/example.conf
sed -i '/enforce_for_root/d' /etc/security/pwquality.conf.d/*.conf /etc/security/pwquality.conf
