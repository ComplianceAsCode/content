#!/bin/bash
# remediation = none

useradd --system --shell /sbin/nologin -u 999 sysuser
useradd -u 1000 testuser

key=SYS_UID_MIN

# Add key as 1st line, drop others
sed -Ei '
1{i\
'"$key"' 201
}
/^'"$key"'/d;
' /etc/login.defs
