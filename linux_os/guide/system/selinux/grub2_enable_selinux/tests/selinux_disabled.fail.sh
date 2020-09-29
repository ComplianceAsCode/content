#!/bin/bash

echo "GRUB_CMDLINE_LINUX=selinux=0 enforcing=0 audit=1" >> /etc/default/grub
echo "selinux=0" >> /etc/grub2.cfg
echo "enforcing=0" >> /etc/grub2.cfg
echo "selinux=0" > /etc/grub.d/tmp_file
echo "rubbish=0" >> /etc/grub.d/tmp_file
echo "enforcing=0" >> /etc/grub.d/tmp_file
