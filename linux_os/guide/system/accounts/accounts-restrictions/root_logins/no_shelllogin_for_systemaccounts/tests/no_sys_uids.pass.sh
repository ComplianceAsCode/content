#!/bin/bash
# remediation = none

# Force unset of SYS_UID values
sed -i '/^SYS_UID_MIN/d' /etc/login.defs
sed -i '/^SYS_UID_MAX/d' /etc/login.defs
