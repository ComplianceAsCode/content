#!/bin/bash
# platform = multi_platform_fedora,Red Hat Enterprise Linux 8, Red Hat Enterprise Linux 9

# Remove init_on_alloc=1 from all boot entries
sed -Ei 's/(^options.*\s)init_on_alloc=1(.*?)$/\1\2/' /boot/loader/entries/*
# But make sure one boot loader entry contains init_on_alloc=1
sed -i '/^options / s/$/ init_on_alloc=1/' /boot/loader/entries/*rescue.conf
sed -Ei 's/(^options.*\s)\$kernelopts(.*?)$/\1\2/' /boot/loader/entries/*rescue.conf

# Make sure /etc/kernel/cmdline contains init_on_alloc=1
if ! grep -qs '^(.*\s)?init_on_alloc=1(\s.*)?$' /etc/kernel/cmdline ; then
    echo "init_on_alloc=1" >> /etc/kernel/cmdline
fi
