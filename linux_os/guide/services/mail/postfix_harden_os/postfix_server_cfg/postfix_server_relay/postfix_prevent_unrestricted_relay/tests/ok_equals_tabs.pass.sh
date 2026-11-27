#!/bin/bash
# packages = postfix

mkdir -p /etc/postfix
printf 'smtpd_client_restrictions\t=\tpermit_mynetworks,reject\n' > /etc/postfix/main.cf
