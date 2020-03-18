#!/bin/bash

mkdir -p /etc/postfix
echo 'smtpd_client_restrictions = permit_mynetworks,dont_reject' > /etc/postfix/main.cf
