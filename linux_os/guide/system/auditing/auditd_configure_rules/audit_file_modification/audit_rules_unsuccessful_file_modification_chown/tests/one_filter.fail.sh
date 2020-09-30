#!/bin/bash


echo "-a always,exit -F arch=b32 -S lchown,fchown,chown,fchownat -F a2&0100 -F exit=-EACCES -F auid>=1000 -F auid!=unset -F key=unsuccesful-perm-change" >> /etc/audit/rules.d/unsuccessful-perm-change.rules
echo "-a always,exit -F arch=b64 -S lchown,fchown,chown,fchownat -F exit=-EACCES -F auid>=1000 -F auid!=unset -F key=unsuccesful-perm-change" >> /etc/audit/rules.d/unsuccessful-perm-change.rules
echo "-a always,exit -F arch=b32 -S lchown,fchown,chown,fchownat -F exit=-EPERM -F auid>=1000 -F auid!=unset -F key=unsuccesful-perm-change" >> /etc/audit/rules.d/unsuccessful-perm-change.rules
echo "-a always,exit -F arch=b64 -S lchown,fchown,chown,fchownat -F exit=-EPERM -F auid>=1000 -F auid!=unset -F key=unsuccesful-perm-change" >> /etc/audit/rules.d/unsuccessful-perm-change.rules
