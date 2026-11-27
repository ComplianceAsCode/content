#!/bin/bash
# platform = Red Hat Enterprise Linux 8

. $SHARED/grub2.sh

GRUB_CFG_ROOT="/boot/grub2"
rm -f "$GRUB_CFG_ROOT/user.cfg"
make_grub_password
rm -f /boot/efi/EFI/redhat/user.cfg
