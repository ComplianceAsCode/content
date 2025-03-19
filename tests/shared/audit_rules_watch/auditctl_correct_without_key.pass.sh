#!/bin/bash
# packages = audit

if [[ "$style" == "modern" ]] ; then
    echo "-a always,exit -F arch=b32 -F path=$path -F perm=wa" >> /etc/audit/audit.rules
    echo "-a always,exit -F arch=b64 -F path=$path -F perm=wa" >> /etc/audit/audit.rules
else
    echo "-w $path -p wa" >> /etc/audit/audit.rules
fi
