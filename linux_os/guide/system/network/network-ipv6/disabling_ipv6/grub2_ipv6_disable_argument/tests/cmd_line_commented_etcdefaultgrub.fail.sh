#!/bin/bash
# platform = multi_platform_sle

# Comments kernel command line in /etc/default/grub
sed -i '/^\s*GRUB_CMDLINE_LINUX=/s//#&/' '/etc/default/grub'
