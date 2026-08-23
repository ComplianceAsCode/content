#!/bin/bash
# packages = audit

# use auditctl
{{{ setup_auditctl_environment() }}}

{{% if 'ubuntu' in product %}}
echo "-w /etc/apparmor/ -p wa -k MAC-policy" > /etc/audit/audit.rules
echo "-w /etc/apparmor.d/ -p wa -k MAC-policy" >> /etc/audit/audit.rules
{{% else %}}
echo "-w /etc/selinux/ -p wa -k MAC-policy" > /etc/audit/audit.rules
{{% endif %}}
