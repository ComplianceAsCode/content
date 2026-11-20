#!/bin/bash
# platform = multi_platform_all 

source common.sh
useradd --system --shell /bin/bash -u 999 sysuser

key=SYS_UID_MIN
printf "%s 50\n" "$key" >> {{{ login_defs_path }}}

key=SYS_UID_MAX
printf "%s 999\n" "$key" >> {{{ login_defs_path }}}
