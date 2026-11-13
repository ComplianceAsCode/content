#!/bin/bash
# platform = Red Hat Enterprise Linux 10
# remediation = none

. $SHARED/grub2.sh

touch "$GRUB_CFG_ROOT/grub.cfg"
rm -f "$GRUB_CFG_ROOT/user.cfg"
