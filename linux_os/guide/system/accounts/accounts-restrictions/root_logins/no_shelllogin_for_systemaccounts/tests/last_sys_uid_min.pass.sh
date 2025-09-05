#!/bin/bash
# remediation = none

useradd --system --shell /sbin/nologin -u 999 sysuser
useradd -u 1000 testuser

key=SYS_UID_MIN

# Add bogus key as 2nd last and valid last line w/o nl
printf "%s 2000\n%s 201" "$key" "$key" >> /etc/login.defs
