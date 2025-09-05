#!/bin/bash
# packages = postfix

echo "inet_interfaces = all" > /etc/postfix/main.cf
systemctl enable postfix
systemctl start postfix
