#!/bin/bash
# platform = multi_platform_fedora,Red Hat Enterprise Linux 8

# Remove systemd.debug-shell from all boot entries
sed -Ei 's/(^options.*)\s\bsystemd.debug-shell\b\S*(.*?)$/\1\2/' /boot/loader/entries/*
# But make sure one boot loader entry contains systemd.debug-shell
sed -i '/^options / s/$/ systemd.debug-shell=1/' /boot/loader/entries/*rescue.conf
sed -Ei 's/(^options.*\s)\$kernelopts(.*?)$/\1\2/' /boot/loader/entries/*rescue.conf

# Make sure /etc/kernel/cmdline doesn't contain systemd.debug-shell
sed -Ei 's/(^.*)systemd\.debug-shell(.*?)$/\1\2/' /etc/kernel/cmdline || true
