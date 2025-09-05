#!/bin/bash

source common.sh

echo "-a always,exit -F path={{{ PATH }}} ${perm_x} -k test_key" >> /etc/audit/rules.d/test_key.rules
