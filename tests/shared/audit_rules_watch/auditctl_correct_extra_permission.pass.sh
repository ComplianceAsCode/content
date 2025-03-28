#!/bin/bash
# packages = audit

perm="wra"
if [[ "$style" == "modern" ]] ; then
    echo "-a always,exit -F arch=b32 -F $filter_type=$path -F perm=$perm -F key=logins" >> /etc/audit/audit.rules
    echo "-a always,exit -F arch=b64 -F $filter_type=$path -F perm=$perm -F key=logins" >> /etc/audit/audit.rules
else
    echo "-w $path -p $perm -k logins" >> /etc/audit/audit.rules
fi
