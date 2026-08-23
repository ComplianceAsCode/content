#!/bin/bash
# packages = audit

if [[ "$style" == "modern" ]] ; then
    echo "-a always,exit -F arch=b32 -F $filter_type=$path -F perm=wa" >> /etc/audit/rules.d/login.rules
    echo "-a always,exit -F arch=b64 -F $filter_type=$path -F perm=wa" >> /etc/audit/rules.d/login.rules
else
    echo "-w $path -p wa" >> /etc/audit/rules.d/login.rules
fi
