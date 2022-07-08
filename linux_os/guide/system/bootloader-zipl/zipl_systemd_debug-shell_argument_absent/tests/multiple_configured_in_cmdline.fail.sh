#!/bin/bash
# platform = multi_platform_fedora,Red Hat Enterprise Linux 8

# Make sure boot loader entries doesn't contain systemd.debug-shell
sed -Ei 's/(^options.*)\s\bsystemd.debug-shell\b\S*(.*?)$/\1\2/' /boot/loader/entries/*

echo "option1 systemd.debug-shell=1 option2" > /etc/kernel/cmdline
