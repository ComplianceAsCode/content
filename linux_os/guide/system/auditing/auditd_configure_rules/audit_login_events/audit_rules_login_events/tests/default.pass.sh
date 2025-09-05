#!/bin/bash
# packages = audit
# remediation = bash

{{% if product in ["ol8", "ol9", "rhel8", "rhel9"] %}}
{{% set faillock_path="/var/log/faillock" %}}
{{% else %}}
{{% set faillock_path="/var/run/faillock" %}}
{{% endif %}}


echo "-w {{{ faillock_path }}} -p wa -k logins" >> /etc/audit/rules.d/logins.rules
echo "-w /var/log/lastlog -p wa -k logins" >> /etc/audit/rules.d/logins.rules
echo "-w /var/log/tallylog -p wa -k logins" >> /etc/audit/rules.d/logins.rules
