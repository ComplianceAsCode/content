#!/bin/bash
# platform = multi_platform_sle

# Removes kernel command line in /etc/default/grub
sed -i '/^\s*GRUB_CMDLINE_LINUX=/d'  '/etc/default/grub'
