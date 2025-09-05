#!/bin/bash
# remediation = bash
{{% if "ubuntu" in product%}}
# packages = auditd
{{% else %}}
# packages = audit
{{% endif %}}

rm -f /etc/audit/rules.d/*
> /etc/audit/audit.rules
