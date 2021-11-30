#!/bin/bash
#

rm -f /etc/audit/rules.d/*
> /etc/audit/audit.rules
echo "-w /var/log/faillog -p a -k logins" >> /etc/audit/rules.d/logins.rules
