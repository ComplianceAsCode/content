#!/bin/bash
# platform = Red Hat Enterprise Linux 8

. $SHARED/grub2.sh

GRUB_CFG_ROOT="/boot/efi/EFI/redhat"
rm -f "$GRUB_CFG_ROOT/user.cfg"
make_grub_password
rm -f /boot/grub2/user.cfg
