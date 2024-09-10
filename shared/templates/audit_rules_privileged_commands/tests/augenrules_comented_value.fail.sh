#!/bin/bash

source common.sh

echo \
"# -a always,exit -F path={{{ PATH }}} ${perm_x} -F auid>={{{ auid }}} -F auid!=unset -k test_key" \
>> /etc/audit/rules.d/test_key.rules
