#!/bin/bash
# remediation = none

cat > /boot/grub2/grub.cfg << EOM
some random line
not set root
EOM
