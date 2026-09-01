#!/bin/bash
# platform = SUSE Linux Enterprise 15, SUSE Linux Enterprise 16

useradd --system --shell /bin/bash -u 999 sysuser

key=SYS_UID_MIN
printf "%s 50\n" "$key" >> {{{ login_defs_drop_in_path }}}

key=SYS_UID_MAX
printf "%s 1000\n" "$key" >> {{{ login_defs_drop_in_path }}}
