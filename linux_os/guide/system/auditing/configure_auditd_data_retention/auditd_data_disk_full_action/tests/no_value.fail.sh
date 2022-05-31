#!/bin/bash
{{% if "ubuntu" in product%}}
# packages = auditd
{{% else %}}
# packages = audit
{{% endif %}}

source common.sh
