#!/bin/bash
#

rm -f /etc/audit/rules.d/*
> /etc/audit/audit.rules
echo "-a never,exit -F arch=b32 -S {{{ NAME }}} -F auid>=1000 -F auid!=unset -F key=delete" >> /etc/audit/rules.d/delete.rules
echo "-a never,exit -F arch=b64 -S {{{ NAME }}} -F auid>=1000 -F auid!=unset -F key=delete" >> /etc/audit/rules.d/delete.rules
