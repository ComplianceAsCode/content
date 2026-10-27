#!/bin/bash
# platform = Red Hat Enterprise Linux 9

. $SHARED/grub2.sh

rm -f /boot/grub2/user.cfg
GRUB_CFG_ROOT=/boot/efi/EFI/redhat
make_grub_password
