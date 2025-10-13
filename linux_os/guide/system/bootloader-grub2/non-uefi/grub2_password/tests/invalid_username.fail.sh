#!/bin/bash

# remediation = none
# platform = Red Hat Enterprise Linux 9, Red Hat Enterprise Linux 10,multi_platform_ubuntu,multi_platform_sle,multi_platform_fedora

. $SHARED/grub2.sh

make_grub_password

{{% if 'ubuntu' in product %}}
test -n "$GRUB_CFG_ROOT" || GRUB_CFG_ROOT=/boot/grub
{{% else %}}
test -n "$GRUB_CFG_ROOT" || GRUB_CFG_ROOT=/boot/grub2
{{% endif %}}

# replace all occurrences of superusers = root
sed -i 's/set superusers="root"/set superusers="use r"/g' "$GRUB_CFG_ROOT/grub.cfg"

set_superusers "use r"
