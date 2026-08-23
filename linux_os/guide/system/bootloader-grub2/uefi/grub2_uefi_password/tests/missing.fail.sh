#!/bin/bash

# remediation = none

. $SHARED/grub2.sh

set_grub_uefi_root

touch "$GRUB_CFG_ROOT/grub.cfg"
rm -f "$GRUB_CFG_ROOT/user.cfg"
