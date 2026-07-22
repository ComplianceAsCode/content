#!/bin/bash
# platform = multi_platform_ubuntu
# packages = grub2

# Remove any existing arg from /etc/default/grub
sed -i 's/\s*{{{ ARG_NAME }}}//g' /etc/default/grub

# Create grub.cfg with the argument in a vmlinuz line
mkdir -p /boot/grub
{
    echo 'menuentry "Ubuntu" {'
    echo '    linux /vmlinuz-5.4.0-mock root=/dev/sda1 ro quiet {{{ ARG_NAME }}}'
    echo '    initrd /initrd.img-5.4.0-mock'
    echo '}'
} > /boot/grub/grub.cfg
