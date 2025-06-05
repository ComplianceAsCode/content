#!/bin/bash

{{% if product == 'slmicro6' %}}
LOGIN_DEFS_PATH=/usr/etc/login.defs
{{% else %}}
LOGIN_DEFS_PATH=/etc/login.defs
{{% endif %}}
sed -i '/^UMASK.*/d' "$LOGIN_DEFS_PATH"
