#!/bin/bash
# remediation = none

cat > /boot/grub2/grub.cfg << EOM
menuentry 'System setup A' {
        fwsetup
        set root='hd0,msdos1'
}

menuentry 'System setup B' {
        fwsetup
}
EOM
