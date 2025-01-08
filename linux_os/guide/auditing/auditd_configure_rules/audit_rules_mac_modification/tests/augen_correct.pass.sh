#!/bin/bash
# packages = audit

{{% if 'ubuntu' in product %}}
echo "-w /etc/apparmor/ -p wa -k MAC-policy" > /etc/audit/rules.d/MAC-policy.rules
echo "-w /etc/apparmor.d/ -p wa -k MAC-policy" >> /etc/audit/rules.d/MAC-policy.rules
{{% else %}}
echo "-w /etc/selinux/ -p wa -k MAC-policy" > /etc/audit/rules.d/MAC-policy.rules
{{% endif %}}

