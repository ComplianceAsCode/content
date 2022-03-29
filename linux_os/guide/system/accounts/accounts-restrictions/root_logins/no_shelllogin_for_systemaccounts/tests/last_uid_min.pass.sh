#!/bin/bash
# remediation = none

useradd --system --shell /sbin/nologin -u 999 sysuser
useradd -u 1000 testuser

key=UID_MIN

# Add bogus key as 2nd last and valid last line w/o nl
# drop SYS_UID so it does not mess
sed -Ei '/^SYS_UID_(MIN|MAX)/d;' /etc/login.defs
printf "%s 2000\n%s 1000" "$key" "$key" >> /etc/login.defs
