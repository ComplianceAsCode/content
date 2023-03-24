#!/bin/bash
#

{{% if "debian" in product or "ubuntu" in product %}}
    {{% set target_perms_octal="0640" %}}
{{% else %}}
    {{% set target_perms_octal="0000" %}}
{{% endif %}}

chmod {{{ target_perms_octal }}} /etc/shadow
