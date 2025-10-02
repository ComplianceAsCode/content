#!/bin/bash

# remediation = none

. $SHARED/grub2.sh

set_grub_uefi_root

make_grub_password
sed -i '/set superusers/d' /boot/grub/grub.cfg
sed -i '/export superusers/d' /boot/grub/grub.cfg
set_superusers "use r"
