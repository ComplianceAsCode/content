#!/bin/bash
# packages = postfix

echo "#inet_interfaces = loopback-only" > /etc/postfix/main.cf
systemctl enable postfix
systemctl start postfix
