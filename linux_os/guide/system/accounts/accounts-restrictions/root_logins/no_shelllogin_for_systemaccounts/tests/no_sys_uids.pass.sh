#!/bin/bash
{{% if product == 'slmicro6' %}}
LOGIN_DEFS_PATH=/usr/etc/login.defs
{{% else %}}
LOGIN_DEFS_PATH=/etc/login.defs
{{% endif %}}

# Force unset of SYS_UID values
sed -i '/^SYS_UID_MIN/d' "${LOGIN_DEFS_PATH}"
sed -i '/^SYS_UID_MAX/d' "${LOGIN_DEFS_PATH}"
