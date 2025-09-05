#!/bin/bash
#

{{% if product in ("ubuntu1804", "opensuse", "sle12", "sle15") %}}
    {{% set target_perms_octal="0600" %}}
{{% else %}}
    {{% set target_perms_octal="0640" %}}
{{% endif %}}

FAKE_KEY=$(mktemp -p /etc/ssh/ XXXX_key)
chmod {{{ target_perms_octal }}}  /etc/ssh/*_key
