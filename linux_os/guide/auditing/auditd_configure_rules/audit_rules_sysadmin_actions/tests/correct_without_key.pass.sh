#!/bin/bash
# packages = audit

{{% if audit_watches_style == "modern" %}}
echo "-a always,exit -F arch=b32 -F path=/etc/sudoers -F perm=wa" >> /etc/audit/rules.d/actions.rules
echo "-a always,exit -F arch=b64 -F path=/etc/sudoers -F perm=wa" >> /etc/audit/rules.d/actions.rules
echo "-a always,exit -F arch=b32 -F dir=/etc/sudoers.d/ -F perm=wa" >> /etc/audit/rules.d/actions.rules
echo "-a always,exit -F arch=b64 -F dir=/etc/sudoers.d/ -F perm=wa" >> /etc/audit/rules.d/actions.rules
{{% else %}}
echo "-w /etc/sudoers -p wa" >> /etc/audit/rules.d/actions.rules
echo "-w /etc/sudoers.d/ -p wa" >> /etc/audit/rules.d/actions.rules
{{% endif %}}
