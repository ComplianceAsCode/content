#!/bin/bash
# packages = postfix

echo "inet_interfaces = localhost" > /etc/postfix/main.cf
systemctl restart postfix
