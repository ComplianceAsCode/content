#!/bin/bash

echo "GRUB_CMDLINE_LINUX=selinux=0 enforcing=0 audit=1" >> /etc/default/grub
sed -i --follow-symlinks "s/selinux=0//gI" /etc/grub2.cfg /etc/grub.d/*
sed -i --follow-symlinks "s/enforcing=0//gI" /etc/grub2.cfg /etc/grub.d/*
