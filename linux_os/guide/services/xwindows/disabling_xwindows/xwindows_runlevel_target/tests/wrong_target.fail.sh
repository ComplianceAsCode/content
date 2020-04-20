#!/bin/bash
# platform = multi_platform_sle,multi_platform_rhv,multi_platform_fedora,Red Hat Enterprise Linux 7,Red Hat Enterprise Linux 8

rm -f /etc/systemd/system/default.target
ln -s /usr/lib/systemd/system/graphical.target /etc/systemd/system/default.target
