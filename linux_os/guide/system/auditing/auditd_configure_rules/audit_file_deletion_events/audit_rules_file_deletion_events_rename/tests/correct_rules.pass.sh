#!/bin/bash


echo "-a always,exit -F arch=b32 -S rename -F auid>=1000 -F auid!=unset -F key=delete" >> /etc/audit/rules.d/delete.rules
echo "-a always,exit -F arch=b64 -S rename -F auid>=1000 -F auid!=unset -F key=delete" >> /etc/audit/rules.d/delete.rules
