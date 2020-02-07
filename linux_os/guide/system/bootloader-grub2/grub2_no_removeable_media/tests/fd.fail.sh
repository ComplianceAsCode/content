#!/bin/bash
# remediation = none

cat > /boot/grub2/grub.cfg << EOM
set root='fd0,msdos1'
EOM
