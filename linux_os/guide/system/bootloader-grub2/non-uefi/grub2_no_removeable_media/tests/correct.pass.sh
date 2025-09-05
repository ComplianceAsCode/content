#!/bin/bash
# remediation = none

cat > /boot/grub2/grub.cfg << EOM
menuentry 'System setup' {
        fwsetup
        set root='hd0,msdos1'
}
EOM
