#!/bin/bash
# remediation = none

cat > /boot/grub2/grub.cfg << EOM
menuentry 'System setup' {
        fwsetup
        set root='cd'
}
EOM
