#!/bin/bash
#

{{% if product in ("ubuntu", "debian") %}}
    {{% set target_perms_octal="0640" %}}
{{% else %}}
    {{% set target_perms_octal="0000" %}}
{{% endif %}}

chmod {{{ target_perms_octal }}} /etc/shadow
