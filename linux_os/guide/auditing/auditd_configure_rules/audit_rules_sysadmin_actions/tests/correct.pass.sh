#!/bin/bash
# packages = audit

{{% if audit_watches_style == "modern" %}}
{{% set watch_key = "identity" if product == "rhel10" else "actions" %}}
{{% set sudoers_d_spec = "-F path=/etc/sudoers.d" if product == "rhel10" else "-F dir=/etc/sudoers.d/" %}}
echo "-a always,exit -F arch=b32 -F path=/etc/sudoers -F perm=wa -F key={{{ watch_key }}}" >> /etc/audit/rules.d/actions.rules
echo "-a always,exit -F arch=b64 -F path=/etc/sudoers -F perm=wa -F key={{{ watch_key }}}" >> /etc/audit/rules.d/actions.rules
echo "-a always,exit -F arch=b32 {{{ sudoers_d_spec }}} -F perm=wa -F key={{{ watch_key }}}" >> /etc/audit/rules.d/actions.rules
echo "-a always,exit -F arch=b64 {{{ sudoers_d_spec }}} -F perm=wa -F key={{{ watch_key }}}" >> /etc/audit/rules.d/actions.rules
{{% else %}}
echo "-w /etc/sudoers -p wa -k actions" >> /etc/audit/rules.d/actions.rules
echo "-w /etc/sudoers.d/ -p wa -k actions" >> /etc/audit/rules.d/actions.rules
{{% endif %}}
