#!/bin/bash

rm -f /etc/default/grub
sed -i --follow-symlinks "s/selinux=0//gI" /etc/grub2.cfg /etc/grub.d/*
sed -i --follow-symlinks "s/enforcing=0//gI" /etc/grub2.cfg /etc/grub.d/*
