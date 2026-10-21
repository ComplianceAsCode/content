#!/bin/bash
# platform = Red Hat Enterprise Linux 8

. $SHARED/grub2.sh

GRUB_CFG_ROOT="/boot/efi/EFI/redhat"
rm -f "$GRUB_CFG_ROOT/grub.cfg"
set_superusers "koskic"
rm -f /boot/grub2/grub.cfg
