#!/bin/bash
# remediation = none

cat > /boot/grub2/grub.cfg << EOM
menuentry 'System setup' {
        fwsetup
        set root='usb0,1'
}
EOM
