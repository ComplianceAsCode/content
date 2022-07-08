#!/bin/bash
# platform = multi_platform_fedora,Red Hat Enterprise Linux 8

# Make sure boot loader entries don't contain systemd.debug-shell
sed -Ei 's/(^options.*)\s\bsystemd.debug-shell\b\S*(.*?)$/\1\2/' /boot/loader/entries/*

# Make sure /etc/kernel/cmdline doesn't contain systemd\.debug-shell
sed -Ei 's/(^.*)systemd\.debug-shell(.*?)$/\1\2/' /etc/kernel/cmdline || true
