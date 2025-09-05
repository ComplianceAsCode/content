#!/bin/bash
#

rm -f /etc/audit/rules.d/*
> /etc/audit/audit.rules
echo "-a always,exit -F arch=b32 -S {{{ NAME }}} -F exit=-EACCES -F auid>={{{ uid_min }}} -F auid!=unset -F key=unsuccesful-perm-change" >> /etc/audit/rules.d/unsuccesful-perm-change.rules
echo "-a always,exit -F arch=b64 -S {{{ NAME }}} -F exit=-EACCES -F auid>={{{ uid_min }}} -F auid!=unset -F key=unsuccesful-perm-change" >> /etc/audit/rules.d/unsuccesful-perm-change.rules
