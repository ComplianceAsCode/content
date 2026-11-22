#!/bin/bash
# packages = postfix,linux-base
# variables = var_postfix_relayhost=smtp.example.com

sed -i "/^#\?relayhost[[:space:]]*=/d" /etc/postfix/main.cf
