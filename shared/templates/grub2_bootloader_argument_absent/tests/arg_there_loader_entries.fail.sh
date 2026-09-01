#!/bin/bash
# platform = Red Hat Enterprise Linux 9,Red Hat Enterprise Linux 10
# packages = grub2,grubby

# Remove any existing arg from /etc/default/grub
sed -i 's/\s*{{{ ARG_NAME }}}//g' /etc/default/grub

# Create a loader entry with the argument on the options line
mkdir -p /boot/loader/entries
rm -f /boot/loader/entries/*.conf
{
    echo 'title OS 1'
    echo 'version 5.0'
    echo 'linux /vmlinuz'
    echo 'initrd /initramfs'
    echo 'options root=UUID=abc-def rhgb ro quiet {{{ ARG_NAME }}}'
} > /boot/loader/entries/mock.conf
