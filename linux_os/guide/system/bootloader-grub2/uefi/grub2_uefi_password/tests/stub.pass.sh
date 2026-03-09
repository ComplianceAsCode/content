#!/bin/bash
# platform = Red Hat Enterprise Linux 8

. $SHARED/grub2.sh

cat <<'EOF' >/boot/efi/EFI/redhat/grub.cfg
search --no-floppy --set prefix --file /boot/grub2/grub.cfg
set prefix=($prefix)/boot/grub2
configfile $prefix/grub.cfg
EOF

GRUB_CFG_ROOT="/boot/grub2"
make_grub_password
