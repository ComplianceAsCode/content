#!/bin/bash

# remediation = none

. $SHARED/grub2.sh

make_grub_password

set_superusers "use r"
