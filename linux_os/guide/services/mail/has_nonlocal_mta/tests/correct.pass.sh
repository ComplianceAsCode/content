#!/bin/bash
# packages = postfix

echo "inet_interfaces = localhost" > /etc/postfix/main.cf
postfix reload || postfix start
