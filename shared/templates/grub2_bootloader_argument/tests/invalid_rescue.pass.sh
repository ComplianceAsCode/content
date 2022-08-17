#!/bin/bash

# platform = Red Hat Enterprise Linux 9
# packages = grub2,grubby

source common.sh

{{{ grub2_bootloader_argument_remediation(ARG_NAME, ARG_NAME_VALUE) }}}

# Rule should find this file and notice it is not right
# - This method hits only limited repos above
echo "I am an invalid boot entry, but nobody should care, because I am rescue" > /boot/loader/entries/trololol-rescue.conf
