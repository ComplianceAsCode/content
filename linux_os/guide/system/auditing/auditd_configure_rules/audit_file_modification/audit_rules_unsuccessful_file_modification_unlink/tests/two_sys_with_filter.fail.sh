#!/bin/bash


echo "-a always,exit -F arch=b32 -S unlink,unlinkat -F a2&0100 -F exit=-EACCES -F auid>=1000 -F auid!=unset -F key=unsuccesful-delete" >> /etc/audit/rules.d/unsuccessful-delete.rules
echo "-a always,exit -F arch=b64 -S unlink,unlinkat -F a2&0100 -F exit=-EACCES -F auid>=1000 -F auid!=unset -F key=unsuccesful-delete" >> /etc/audit/rules.d/unsuccessful-delete.rules
echo "-a always,exit -F arch=b32 -S unlink,unlinkat -F a2&0100 -F exit=-EPERM -F auid>=1000 -F auid!=unset -F key=unsuccesful-delete" >> /etc/audit/rules.d/unsuccessful-delete.rules
echo "-a always,exit -F arch=b64 -S unlink,unlinkat -F a2&0100 -F exit=-EPERM -F auid>=1000 -F auid!=unset -F key=unsuccesful-delete" >> /etc/audit/rules.d/unsuccessful-delete.rules
