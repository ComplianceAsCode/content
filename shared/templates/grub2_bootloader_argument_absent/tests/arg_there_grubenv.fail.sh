#!/bin/bash

# platform = Red Hat Enterprise Linux 8
# packages = grub2-tools,grubby

# Adds audit argument from kernel command line in /boot/grub2/grubenv
file="/boot/grub2/grubenv"
if ! grep -q '^.*{{{ ARG_NAME }}}.*'  "$file" ; then
    grub2-editenv - set "$(grub2-editenv - list | grep kernelopts) {{{ ARG_NAME }}}"
fi

