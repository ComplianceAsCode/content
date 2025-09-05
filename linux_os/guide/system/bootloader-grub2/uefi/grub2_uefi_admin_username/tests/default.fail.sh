#!/bin/bash

# remediation = none

. $SHARED/grub2.sh

set_grub_uefi_root

set_superusers "root"
