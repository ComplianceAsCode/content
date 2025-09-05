#!/bin/bash
echo "-a always,exit -F arch=b32 -S renameat2 -F exit=-EACCES -F auid>=1000 -F auid!=unset -F key=access" >> /etc/audit/rules.d/audit.rules
echo "-a always,exit -F arch=b32 -S renameat2 -F exit=-EPERM -F auid>=1000 -F auid!=unset -F key=access" >> /etc/audit/rules.d/audit.rules
echo "-a always,exit -F arch=b64 -S renameat2 -F exit=-EACCES -F auid>=1000 -F auid!=unset -F key=access" >> /etc/audit/rules.d/audit.rules
echo "-a always,exit -F arch=b64 -S renameat2 -F exit=-EPERM -F auid>=1000 -F auid!=unset -F key=access" >> /etc/audit/rules.d/audit.rules

