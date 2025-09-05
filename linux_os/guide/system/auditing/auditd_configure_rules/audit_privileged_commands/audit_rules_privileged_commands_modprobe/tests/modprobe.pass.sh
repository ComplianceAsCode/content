#!/bin/bash

res=`cat /etc/audit/rules.d/audit.rules | grep -w "\-w /sbin/modprobe -p x -k modules" | wc -l`

if [[ res -eq 0 ]]
  then
     echo "-w /sbin/modprobe -p x -k modules" >> /etc/audit/rules.d/audit.rules
fi
