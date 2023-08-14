#!/bin/bas
# platform = Red Hat Enterprise Linux 7,sle12,sle15

# Removes kernel command line in /etc/default/grub
sed -i '/^\s*GRUB_CMDLINE_LINUX=/s//#&/' '/etc/default/grub'
