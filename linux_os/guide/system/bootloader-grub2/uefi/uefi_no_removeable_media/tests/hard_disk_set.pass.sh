#!/bin/bash

# remediation = none

. $SHARED/grub2.sh

set_grub_uefi_root

# make the check applicable since it tries to detect this directory first
# mkdir -p /sys/firmware/efi

set_root_unquoted "'hd0,msdos1'"
