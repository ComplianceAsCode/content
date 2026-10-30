#!/bin/bash
# platform = SUSE Linux Enterprise 15, SUSE Linux Enterprise 16

source common.sh
useradd --system --shell /sbin/nologin -u 50 sysuser

key=SYS_UID_MIN
printf "%s 50\n" "$key" >> {{{ login_defs_drop_in_path }}}

key=SYS_UID_MAX
printf "%s 999\n" "$key" >> {{{ login_defs_drop_in_path }}}
