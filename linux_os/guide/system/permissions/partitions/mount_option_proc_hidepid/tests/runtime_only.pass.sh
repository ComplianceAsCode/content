#!/bin/bash
# variables = var_mount_option_proc_hidepid=2

sed -i '/^proc/d' /etc/fstab
mount -oremount,hidepid=2 /proc
