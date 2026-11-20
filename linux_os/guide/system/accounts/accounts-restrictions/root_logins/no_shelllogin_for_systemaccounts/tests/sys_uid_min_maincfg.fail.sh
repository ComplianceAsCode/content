#!/bin/bash
{{% if product in ["rhel9", "rhel10"] %}}
# platform = Not Applicable
{{% endif %}}

source common.sh
useradd --system --shell /bin/bash -u 149 sysuser

key=SYS_UID_MIN
printf "%s 150\n" "$key" >> {{{ login_defs_path }}}

key=SYS_UID_MAX
printf "%s 500\n" "$key" >> {{{ login_defs_path }}}
