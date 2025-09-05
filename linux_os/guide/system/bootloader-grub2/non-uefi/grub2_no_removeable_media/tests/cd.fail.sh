#!/bin/bash
# remediation = none

cat > /boot/grub2/grub.cfg << EOM
set root='cd'
EOM
