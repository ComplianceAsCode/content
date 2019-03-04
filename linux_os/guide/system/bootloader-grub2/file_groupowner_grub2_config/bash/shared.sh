# platform = multi_platform_all
# reboot = false
# strategy = configure
# complexity = low
# disruption = low

GRUB2_CONF_NON_EFI=/boot/grub2/grub.cfg
GRUB2_CONF_EFI=/boot/efi/EFI/redhat/grub.cfg

if [ -f $GRUB2_CONF_EFI ]; then
    chgrp 0 $GRUB2_CONF_EFI
elif [ -f $GRUB2_CONF_NON_EFI ]; then
    chgrp 0 $GRUB2_CONF_NON_EFI
fi
