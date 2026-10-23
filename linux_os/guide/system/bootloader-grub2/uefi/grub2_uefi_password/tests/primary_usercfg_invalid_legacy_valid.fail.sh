#!/bin/bash
# platform = Red Hat Enterprise Linux 8

. $SHARED/grub2.sh

GRUB_CFG_ROOT="/boot/efi/EFI/redhat"
rm -f "$GRUB_CFG_ROOT/user.cfg"
make_grub_password

GRUB_CFG_ROOT="/boot/grub2"
mkdir -p "$GRUB_CFG_ROOT"
rm -f "$GRUB_CFG_ROOT/user.cfg"
touch "$GRUB_CFG_ROOT/user.cfg"
