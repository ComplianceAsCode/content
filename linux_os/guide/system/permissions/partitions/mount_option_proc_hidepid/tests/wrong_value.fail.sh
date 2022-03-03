#!/bin/bash
# variables = var_mount_option_proc_hidepid=2

sed -i '/^proc/d' /etc/fstab
echo "proc  /proc   proc    defaults,hidepid=0" >> /etc/fstab
mount -oremount /proc
