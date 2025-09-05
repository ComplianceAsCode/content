#!/bin/bash

useradd --system --shell /sbin/nologin -u 999 sysuser
useradd -u {{{ uid_min }}} testuser

key=SYS_UID_MAX

# Add key as 1st line, drop others
sed -Ei '
1{i\
'"$key"' 999
}
/^'"$key"'/d;
' /etc/login.defs

key=SYS_UID_MIN

# Add key as 1st line, drop others
sed -Ei '
1{i\
'"$key"' 201
}
/^'"$key"'/d;
' /etc/login.defs
