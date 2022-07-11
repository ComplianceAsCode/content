#!/bin/bash
# platform = multi_platform_fedora,Red Hat Enterprise Linux 8

# Make sure boot loader entries doesn't contain systemd.debug-shell
sed -Ei 's/(^options.*)\s\bsystemd.debug-shell\b\S*(.*?)$/\1\2/' /boot/loader/entries/*

# Make sure /etc/kernel/cmdline contains systemd.debug-shell
if ! grep -qs '^(.*\s)?systemd.debug-shell(\s.*)?$' /etc/kernel/cmdline ; then
    echo "systemd.debug-shell=1" >> /etc/kernel/cmdline
fi
