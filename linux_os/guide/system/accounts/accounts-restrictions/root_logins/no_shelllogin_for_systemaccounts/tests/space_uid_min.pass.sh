#!/bin/bash
{{% if product == 'slmicro6' %}}
LOGIN_DEFS_PATH=/usr/etc/login.defs
{{% else %}}
LOGIN_DEFS_PATH=/etc/login.defs
{{% endif %}}

useradd --system --shell /sbin/nologin -u 999 sysuser
useradd -u {{{ uid_min }}} testuser

key=UID_MIN

# Add bogus key as 2nd last and valid last line w/o nl
# drop SYS_UID so it does not mess
sed -Ei '/^SYS_UID_(MIN|MAX)/d;' "${LOGIN_DEFS_PATH}"
printf "%s 2000\n\t%s {{{ uid_min }}}\n" "$key" "$key" >> "${LOGIN_DEFS_PATH}"
