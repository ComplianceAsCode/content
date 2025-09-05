#!/bin/bash
#

rm -f /etc/audit/rules.d/*
> /etc/audit/audit.rules
echo "-a always,exit -F arch=b32 -S {{{ NAME }}} -F auid>={{{ uid_min }}} -F auid!=unset -F key=delete" >> /etc/audit/rules.d/delete.rules
echo "-a always,exit -F arch=b64 -S {{{ NAME }}} -F auid>={{{ uid_min }}} -F auid!=unset -F key=delete" >> /etc/audit/rules.d/delete.rules
