#!/bin/bash

. $SHARED/grub2.sh

set_grub_uefi_root

rm -f "$GRUB_CFG_ROOT/grub.cfg"

