#!/bin/bash
# packages = audit

if [[ "$style" == "modern" ]] ; then
    sed -i "/$filter_type=$(echo "$path" | sed 's/\//\\\//g')/d" /etc/audit/audit.rules 
    echo "-a always,exit -F arch=b32 -F $filter_type=$path -F perm=w -F key=logins" >> /etc/audit/audit.rules
    echo "-a always,exit -F arch=b64 -F $filter_type=$path -F perm=w -F key=logins" >> /etc/audit/audit.rules
else
    sed -i "\#-w $path#d" /etc/audit/audit.rules
    echo "-w $path -p w -k logins" >> /etc/audit/audit.rules
fi
