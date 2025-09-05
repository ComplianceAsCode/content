#!/bin/bash

echo "selinux=0" >> /etc/grub2.cfg
echo "enforcing=0" >> /etc/grub2.cfg
sed -i --follow-symlinks "s/selinux=0//gI" /etc/default/grub /etc/grub.d/*
sed -i --follow-symlinks "s/enforcing=0//gI" /etc/default/grub /etc/grub.d/*
