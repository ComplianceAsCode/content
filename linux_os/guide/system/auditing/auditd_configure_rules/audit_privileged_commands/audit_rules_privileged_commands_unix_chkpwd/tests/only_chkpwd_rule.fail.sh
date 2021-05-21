#!/bin/bash

mkdir -p /etc/audit/rules.d/
echo "-a always,exit -F path=/sbin/unix_chkpwd -F perm=x -F auid>=1000 -F auid!=unset -F key=privileged" >> /etc/audit/rules.d/privileged.rules
