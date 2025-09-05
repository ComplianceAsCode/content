#!/bin/bash
# packages = postfix

systemctl enable postfix
systemctl start postfix
echo "inet_interfaces = all,loopback-only" > /etc/postfix/main.cf
