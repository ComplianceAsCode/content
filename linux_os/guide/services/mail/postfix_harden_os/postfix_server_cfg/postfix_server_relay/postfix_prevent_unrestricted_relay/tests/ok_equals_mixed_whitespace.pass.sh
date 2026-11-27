#!/bin/bash
# packages = postfix

mkdir -p /etc/postfix
printf 'smtpd_client_restrictions \t =\t  permit_mynetworks,reject\n' > /etc/postfix/main.cf
