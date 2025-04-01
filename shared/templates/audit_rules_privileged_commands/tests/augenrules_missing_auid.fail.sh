#!/bin/bash

source common.sh

echo "-a always,exit -F arch=b32 -F path={{{ PATH }}} ${perm_x} -F auid!=unset -k test_key" >> /etc/audit/rules.d/test_key.rules
echo "-a always,exit -F arch=b64 -F path={{{ PATH }}} ${perm_x} -F auid!=unset -k test_key" >> /etc/audit/rules.d/test_key.rules
