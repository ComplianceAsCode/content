#!/bin/bash
# packages = postfix

echo "inet_interfaces = some_different_interface,loopback-only" > /etc/postfix/main.cf
