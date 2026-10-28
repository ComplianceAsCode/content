#!/bin/bash

if ! [ -f "/etc/grub2.cfg" ]; then
    touch /etc/grub2.cfg
fi

rm -f /etc/default/grub
sed -i --follow-symlinks "s/selinux=0//gI" /etc/grub2.cfg /etc/grub.d/*
sed -i --follow-symlinks "s/enforcing=0//gI" /etc/grub2.cfg /etc/grub.d/*
