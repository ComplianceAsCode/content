#!/bin/bash
# packages = postfix

echo "inet_interfaces = all" > /etc/postfix/main.cf
systemctl stop postfix
systemctl disable postfix
