#!/bin/bash
# packages = postfix

echo "inet_interfaces = localhost" > /etc/postfix/main.cf
postfix stop || postfix start
