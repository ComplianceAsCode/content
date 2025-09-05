#!/bin/bash
# packages = postfix

echo "#inet_interfaces = loopback-only" > /etc/postfix/main.cf
echo "inet_interfaces = something_different" >> /etc/postfix/main.cf
