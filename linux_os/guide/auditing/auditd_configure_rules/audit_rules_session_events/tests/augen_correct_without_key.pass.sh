#!/bin/bash

rm -rf /etc/audit/rules.d/*
rm /etc/audit/audit.rules

{{% if audit_watches_style == "modern" %}}
cat << EOF > /etc/audit/rules.d/session.rules
-a always,exit -F arch=b32 -F path=/var/run/utmp -F perm=wa
-a always,exit -F arch=b64 -F path=/var/run/utmp -F perm=wa
-a always,exit -F arch=b32 -F path=/var/log/btmp -F perm=wa
-a always,exit -F arch=b64 -F path=/var/log/btmp -F perm=wa
-a always,exit -F arch=b32 -F path=/var/log/wtmp -F perm=wa
-a always,exit -F arch=b64 -F path=/var/log/wtmp -F perm=wa
EOF
{{% else %}}
echo "-w /var/run/utmp -p wa" >> /etc/audit/rules.d/session.rules
echo "-w /var/log/btmp -p wa" >> /etc/audit/rules.d/session.rules
echo "-w /var/log/wtmp -p wa" >> /etc/audit/rules.d/session.rules
{{% endif %}}
