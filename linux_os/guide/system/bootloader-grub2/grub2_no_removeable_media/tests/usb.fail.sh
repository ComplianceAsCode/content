#!/bin/bash

cat > /boot/grub2/grub.cfg << EOM
set root='usb0,1'
EOM
