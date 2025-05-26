#!/bin/bash
# packages = postfix
# remediation = none

echo "inet_interfaces = all" > /etc/postfix/main.cf
postfix stop || postfix start
