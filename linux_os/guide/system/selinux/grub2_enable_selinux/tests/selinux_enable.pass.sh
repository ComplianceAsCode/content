#!/bin/bash

sed -i --follow-symlinks "s/selinux=0//gI" /etc/default/grub /etc/grub2.cfg /etc/grub.d/*
sed -i --follow-symlinks "s/enforcing=0//gI" /etc/default/grub /etc/grub2.cfg /etc/grub.d/*
