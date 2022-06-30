#!/bin/bash
# packages = postfix

mkdir -p /etc/postfix
echo 'smtpd_client_restrictions = permit_mynetworks,reject' > /etc/postfix/main.cf
