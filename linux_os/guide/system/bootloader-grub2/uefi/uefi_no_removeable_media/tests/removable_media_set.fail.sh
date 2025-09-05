#!/bin/bash

# remediation = none

. $SHARED/grub2.sh

set_grub_uefi_root

echo "menuentry 'System setup' {
        fwsetup
        set root=(usb0,msdos1')
}" >> "$GRUB_CFG_ROOT"/grub.cfg
