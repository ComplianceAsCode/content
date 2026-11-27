#!/bin/bash

if ! [ -d "/etc/grub.d" ]; then
    mkdir -p /etc/grub.d
fi
if ! [ -d "/etc/default" ]; then
    mkdir -p /etc/default
fi
if ! [ -f "/etc/grub2.cfg" ]; then
    touch /etc/grub2.cfg
fi

echo "GRUB_CMDLINE_LINUX=selinux=0 enforcing=0 audit=1" >> /etc/default/grub
echo "selinux=0" >> /etc/grub2.cfg
echo "enforcing=0" >> /etc/grub2.cfg
echo "selinux=0" > /etc/grub.d/tmp_file
echo "enforcing=0" >> /etc/grub.d/tmp_file
