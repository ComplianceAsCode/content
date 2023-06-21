#!/bin/bash

useradd --system --shell /sbin/nologin -u 999 sysuser
useradd -u {{{ uid_min }}} testuser

key=UID_MIN

# Add key as 1st line, drop others
sed -Ei '
1{i\
'"$key"' {{{ uid_min }}}
}
/^(SYS_)?UID_(MIN|MAX)/d;
' /etc/login.defs
