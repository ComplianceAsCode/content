#!/bin/bash
# packages = postfix
# remediation = none

echo "inet_interfaces = all" > /etc/postfix/main.cf
postfix reload || postfix start
