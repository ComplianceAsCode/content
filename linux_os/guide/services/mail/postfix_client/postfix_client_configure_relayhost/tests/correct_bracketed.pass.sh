#!/bin/bash
# packages = postfix,linux-base
# variables = var_postfix_relayhost=[smtp.example.com]:587

sed -i "/^#\?relayhost[[:space:]]*=/d" /etc/postfix/main.cf
echo "relayhost = [smtp.example.com]:587" >> /etc/postfix/main.cf
