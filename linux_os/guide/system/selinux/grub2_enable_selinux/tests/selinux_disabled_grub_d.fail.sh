#!/bin/bash

echo "selinux=0" > /etc/grub.d/tmp_file
echo "enforcing=0" >> /etc/grub.d/tmp_file
sed -i --follow-symlinks "s/selinux=0//gI" /etc/default/grub /etc/grub2.cfg
sed -i --follow-symlinks "s/enforcing=0//gI" /etc/default/grub /etc/grub2.cfg
