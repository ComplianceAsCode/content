#!/bin/bash

# remediation = none
# platform = Red Hat Enterprise Linux 9, Red Hat Enterprise Linux 10,multi_platform_ubuntu,multi_platform_sle,multi_platform_fedora

. $SHARED/grub2.sh

make_grub_password

set_superusers "use r"
