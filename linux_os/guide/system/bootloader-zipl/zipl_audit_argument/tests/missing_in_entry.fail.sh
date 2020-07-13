#!/bin/bash
# platform = multi_platform_fedora,Red Hat Enterprise Linux 8

# Remove audit=1 from all boot entries
sed -Ei 's/(^options.*\s)audit=1(.*?)$/\1\2/' /boot/loader/entries/*
# But make sure one boot loader entry contains audit=1
sed -i '/^options / s/$/ audit=1/' /boot/loader/entries/*rescue.conf
sed -Ei 's/(^options.*\s)\$kernelopts(.*?)$/\1\2/' /boot/loader/entries/*rescue.conf

# Make sure /etc/kernel/cmdline contains audit=1
if ! grep -qs '^(.*\s)?audit=1(\s.*)?$' /etc/kernel/cmdline ; then
    echo "audit=1" >> /etc/kernel/cmdline
fi
