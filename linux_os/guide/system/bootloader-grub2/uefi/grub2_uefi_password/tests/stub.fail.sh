#!/bin/bash
# platform = Red Hat Enterprise Linux 8

. $SHARED/grub2.sh

cp "/boot/efi/EFI/redhat/user.cfg" "/boot/grub2/user.cfg"
cat <<'EOF' >/boot/efi/EFI/redhat/grub.cfg
search --no-floppy --set prefix --file /boot/grub2/grub.cfg
set prefix=($prefix)/boot/grub2
configfile $prefix/grub.cfg
EOF
rm -rf "/boot/grub2/user.cfg"
