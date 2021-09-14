#!/bin/bash
#

rm -f /etc/audit/rules.d/*
> /etc/audit/audit.rules
echo "-w {{{ PATH }}} -p a -k logins" >> /etc/audit/rules.d/logins.rules
