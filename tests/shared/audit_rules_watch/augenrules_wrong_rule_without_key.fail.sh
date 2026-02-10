#!/bin/bash
# packages = audit


if [[ "$style" == "modern" ]] ; then
    sed -i "/$filter_type=$(echo "$path" | sed 's/\//\\\//g')/d" /etc/audit/rules.d/*.rules 2>/dev/null || true
    echo "-a always,exit -F arch=b32 -F $filter_type=$path -F perm=w" >> /etc/audit/rules.d/login.rules
    echo "-a always,exit -F arch=b64 -F $filter_type=$path -F perm=w" >> /etc/audit/rules.d/login.rules
else
    sed -i "\#-w $path#d" /etc/audit/rules.d/*.rules 2>/dev/null || true
    echo "-w $path -p w" >> /etc/audit/rules.d/login.rules
fi
