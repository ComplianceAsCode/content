#!/bin/bash
# platform = SUSE Linux Enterprise 15, SUSE Linux Enterprise 16

useradd --system --shell /bin/bash -u 149 sysuser

key=SYS_UID_MIN
printf "%s 150\n" "$key" >> {{{ login_defs_drop_in_path }}}

key=SYS_UID_MAX
printf "%s 500\n" "$key" >> {{{ login_defs_drop_in_path }}}
