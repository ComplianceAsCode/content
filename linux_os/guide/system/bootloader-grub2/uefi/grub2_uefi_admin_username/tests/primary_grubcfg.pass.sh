#!/bin/bash
# platform = Red Hat Enterprise Linux 8

. $SHARED/grub2.sh

GRUB_CFG_ROOT="/boot/grub2"
rm -f "$GRUB_CFG_ROOT/grub.cfg"
set_superusers "koskic"
rm -f /boot/efi/EFI/redhat/grub.cfg
