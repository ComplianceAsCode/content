#!/bin/bash
# platform = Red Hat Enterprise Linux 9

. $SHARED/grub2.sh

mkdir -p /boot/grub2
cat << EOF > /boot/grub2/user.cfg
# GRUB2_PASSWORD=grub.pbkdf2.sha512.invalid
EOF
GRUB_CFG_ROOT=/boot/efi/EFI/redhat
make_grub_password
