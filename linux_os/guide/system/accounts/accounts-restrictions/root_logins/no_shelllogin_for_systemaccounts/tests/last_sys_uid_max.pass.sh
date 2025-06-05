#!/bin/bash
{{% if product == 'slmicro6' %}}
LOGIN_DEFS_PATH=/usr/etc/login.defs
{{% else %}}
LOGIN_DEFS_PATH=/etc/login.defs
{{% endif %}}

useradd --system --shell /sbin/nologin -u 999 sysuser
useradd -u {{{ uid_min }}} testuser

key=SYS_UID_MIN

printf "%s 201\n" "$key" >> "${LOGIN_DEFS_PATH}"

key=SYS_UID_MAX

# Add bogus key as 2nd last and valid last line w/o nl
printf "%s 2000\n%s 999" "$key" "$key" >> "${LOGIN_DEFS_PATH}"
